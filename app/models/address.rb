# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true
  validates :street, :city, :state, :postal_code, presence: true
  validate :validate_and_geocode, if: :validate_and_geocode?

  ADDRESS_FIELDS = %i[street street2 city state postal_code].freeze

  def to_s
    [street, street2, city, state, postal_code].compact.join(' ')
  end

  def skip_api_validation!
    self.skip_api_validation = true
  end

  private
  attr_accessor :skip_api_validation
  alias skip_api_validation? skip_api_validation

  def validate_and_geocode?
    !skip_api_validation? && ADDRESS_FIELDS.any? { |f| changes.key?(f.to_s) }
  end

  def validate_and_geocode
    address = ADDRESS_FIELDS.map { |v| send(v).presence }.compact.join(", ")

    if address.present?
      verifier = MainStreet::AddressVerifier.new(address)
      if verifier.success?
        self.assign_attributes(latitude: verifier.latitude, longitude: verifier.longitude)
      else
        errors.add(:base, verifier.failure_message)
      end
    end
  end
end
