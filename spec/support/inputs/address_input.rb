# frozen_string_literal: true

class AddressInput < Rarchitecture::ApplicationInput
  required(:street).string
  optional(:city).string
  optional(:zip_code).string
  optional(:country).hash do
    required(:name).string
    optional(:code).string
  end

  transform_key(country: :country_attributes)
end
