# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build :user }
  it 'has a valid factory' do
    expect(user.valid?).to be(true)
  end

  describe '.volunteers' do
    let!(:volunteer) { create :user, role: 'volunteer' }
    let!(:coordinator) { create :user, role: 'coordinator' }
    let!(:social_worker) { create :user, role: 'social_worker' }
    it 'returns a list of users that are volunteers or coordinators' do
      expect(described_class.volunteers).to contain_exactly(volunteer, coordinator)
      expect(described_class.volunteers).not_to include(social_worker)
    end
  end

  describe '{role}?' do
    it 'checks the role' do
      expect(user.volunteer?).to eq(true)
    end
  end

  describe '#has_at_least_one_office' do
    it 'adds an error if no office is associated' do
      user.offices.clear
      expect(user.valid?).to be(false)
      expect(user.errors.full_messages.first).to eq('At least one office assignment is required')
    end
  end

  describe '#name' do
    context 'first & last name are present' do
      it 'returns first & last name' do
        expect(user.name).to eq('Test User')
      end
    end

    context 'first & last name are nil' do
      it 'returns email address' do
        user.assign_attributes(first_name: nil, last_name: nil)
        expect(user.name).to eq(user.email)
      end
    end
  end

  describe '.available_within' do
    let(:time) { { start_at: 1.day.from_now, end_at: 1.day.from_now + 1.hour } }
    subject { User.available_within(*time.values) }

    context 'user has no blockouts' do
      let!(:user) { create :user }

      it 'includes the user' do
        expect(subject).to include(user)
      end
    end

    context 'user has blockouts with overlap' do
      let(:user) { build :user }
      let!(:blockout) { create :blockout, user: user, **time }

      it 'excludes the user' do
        expect(subject).not_to include(user)
      end
    end

    context 'user has blockouts with no overlap' do
      let(:user) { build :user }
      let!(:blockout) { create :blockout, user: user, start_at: 1.hour.from_now, end_at: 2.hours.from_now }

      it 'includes the user' do
        expect(subject).to include(user)
      end
    end
  end

  describe '.speaks_language' do
    let(:language) { create :language }
    subject { User.speaks_language(language) }

    it 'includes primary and secondary speakers' do
      primary_speaker = create :user, first_language: language
      secondary_speaker = create :user, second_language: language
      expect(subject).to include(primary_speaker, secondary_speaker)
    end
  end
end
