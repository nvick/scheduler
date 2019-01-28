# frozen_string_literal: true

FactoryBot.define do
  factory :need do
    association :office, strategy: :build
    user { association :user, offices: [@instance.office], role: 'social_worker', strategy: :build }
    start_at { Time.zone.now }
    expected_duration { 120 }
    number_of_children { 1 }
  end
end