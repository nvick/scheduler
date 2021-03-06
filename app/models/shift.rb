# frozen_string_literal: true

class Shift < ApplicationRecord
  belongs_to :need
  belongs_to :user, optional: true
  before_destroy :notify_user_of_cancelation, if: -> { user.present? }
  validates :start_at, :duration, presence: true

  def end_at
    start_at.advance(minutes: duration)
  end

  def notify_user_of_cancelation(user_to_notify = user)
    time = start_at.in_time_zone(user_to_notify.time_zone).to_s(:short_with_time)
    SendTextMessageJob.perform_later(user_to_notify.phone, "Your shift on #{time} has been canceled.")
  end
end
