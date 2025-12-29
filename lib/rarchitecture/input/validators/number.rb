# frozen_string_literal: true

require_relative "common"

module Input
  module Validators
    # NumberValidation
    #
    # Responsibilities:
    # - Ensure an attribute value is Numeric when present.
    # - Optionally enforce digit-length constraints via `min`/`max`.
    # - Register a default value on the declaring class when provided.
    #
    # Usage examples:
    #   optional(:age).number
    #   required(:phone).number(min: 10, max: 13)
    module NumberValidation
      # Attach number validations to `klass` for the attribute `name`.
      # Accepts `default`, `min`, and `max` to configure digit-length
      # constraints. Extra options are ignored for forward compatibility.
      def self.attach(klass, name, **options)
        add_numeric_type_check(klass, name, **options)
        Common.add_default(klass, name, options[:default])
        return unless options[:length]

        validate_digit_length(klass, name, options[:length])
      end

      # Add a type-checking validator that ensures the value is Numeric
      # when present. Implemented as an instance `validate` block on the
      # declaring class to align with ActiveModel semantics.
      def self.add_numeric_type_check(klass, name, **options)
        format = options[:format] || {}

        klass.validate do
          value = self[name]
          next if value.is_a?(Numeric)
          next if value.blank? && format[:allow_blank]

          errors.add(:base, format[:message] || "#{name.to_s.titleize} must be a number")
        end
      end

      # Attach an ActiveModel-style digit-length validator. Converts the
      # value to a string, strips non-digits, and measures length to
      # support numeric identifiers like phone numbers.
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
      def self.validate_digit_length(klass, name, length)
        klass.validate do
          value = self[name]
          next if value.nil?

          digits = value.to_s.gsub(/\D/, "").length
          too_short = length[:minimum] && digits < length[:minimum]
          too_long = length[:maximum] && digits > length[:maximum]

          too_short_error = length[:too_short]
          too_short_error ||=
            "#{name.to_s.titleize} is too short (minimum is #{length[:minimum]} digits)"
          errors.add(:base, too_short_error) if too_short

          too_long_error = length[:too_long]
          too_long_error ||=
            "#{name.to_s.titleize} is too long (maximum is #{length[:maximum]} digits)"
          errors.add(:base, too_long_error) if too_long
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
