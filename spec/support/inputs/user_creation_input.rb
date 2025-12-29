# frozen_string_literal: true

class UserCreationInput < RArchitecture::ApplicationInput
  required(:email).string
  optional(:address).hash(from: AddressInput, format: { allow_blank: true })

  transform_key(address: :address_attributes)

  validate :check_email_domain

  private

  def check_email_domain
    return unless email
    return if email.end_with?("@example.com")

    errors.add(:email, "must be from example.com domain")
  end
end
