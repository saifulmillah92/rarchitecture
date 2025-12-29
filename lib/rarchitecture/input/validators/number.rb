# frozen_string_literal: true

require_relative "common"

module Input
  module Validators
    # NumberValidation
    #
    # Responsibilities:
    # - Ensure an attribute value is Numeric when present.
    # - Optionally enforce digit-length constraints via `minimum` / `maximum`.
    # - Register a default value on the declaring class when provided.
    #
    # Usage examples:
    #   optional(:age).number
    #   required(:phone).number(length: { minimum: 10, maximum: 13 })
    #
    # Options:
    # - default: sets a default numeric value on the declaring class.
    # - format:
    #     :message     => custom error message
    #     :allow_blank => allow empty values without error
    # - length:
    #     :minimum   => minimum allowed digit length
    #     :maximum   => maximum allowed digit length
    #     :too_short => custom error message when below minimum
    #     :too_long  => custom error message when above maximum
    module NumberValidation
      # Attach number validations to `klass` for the attribute `name`.
      # Accepts `default`, `format`, and `length` options. Extra options
      # are ignored for forward compatibility.
      def self.attach(klass, name, **options)
        add_numeric_type_check(klass, name, **options)
        Common.add_default(klass, name, options[:default])
        return unless options[:length]

        validate_digit_length(klass, name, options[:length])
      end

      # Add a type-checking validator that ensures the value of `name`
      # is Numeric when present. Respects `allow_blank` to skip validation
      # on empty values, and uses a custom error message if supplied.
      # Implemented as an instance-level `validate` block on the declaring
      # class to align with ActiveModel semantics.
      def self.add_numeric_type_check(klass, name, **options)
        format = options[:format] || {}

        Common.with_value(klass, name, format) do |value, record, message|
          next if value.is_a?(Numeric)

          record.errors.add(:base, message || "#{name.to_s.titleize} must be a number")
        end
      end

      # Add a digit-length validator for the attribute `name`. Converts
      # the value to a string, strips non-digits, and measures length to
      # support numeric identifiers like phone numbers. Provides default
      # error messages unless custom ones are supplied.
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
      def self.validate_digit_length(klass, name, length)
        klass.validate do
          value = self[name]
          next if value.nil?

          digits = value.to_s.gsub(/\D/, "").length
          too_short = length[:minimum] && digits < length[:minimum]
          too_long  = length[:maximum] && digits > length[:maximum]

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
