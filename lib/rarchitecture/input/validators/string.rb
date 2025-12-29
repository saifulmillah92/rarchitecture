# frozen_string_literal: true

require_relative "common"

module Input
  module Validators
    # StringValidation
    #
    # Responsibilities:
    # Responsibilities:
    # - Ensure an attribute value is a String when present.
    # - Optionally enforce minimum/maximum length constraints.
    # - Register a default value on the declaring class when provided.
    # - Support format validation with regex, custom messages, and blank allowance.
    #
    # Usage examples:
    #   optional(:name).string
    #   required(:code).string(minimum: 3, maximum: 10)
    # For more detailed usage and edge cases, see `input_spec.rb`.
    module StringValidation
      # Attach string validations to `klass` for the attribute `name`.
      # Accepts `default`, `format`, and `length` options. Additional options are
      # ignored to keep the API forward-compatible.
      def self.attach(klass, name, **options)
        add_string_type_check(klass, name, **options)
        Common.add_default(klass, name, options[:default])

        validate_any_of_values(klass, name, **options)
        validate_format(klass, name, **options)
        return unless options[:length]

        validate_length(klass, name, options[:length])
      end

      # Add a type-checking validator that ensures the value of `name`
      # is a String when present. Respects `allow_blank` to skip validation
      # on empty values, and uses a custom error message if supplied.
      # Attached as an instance-level `validate` block on the declaring class
      # to keep validation semantics consistent.
      def self.add_string_type_check(klass, name, **options)
        format = options[:format] || {}

        klass.validate do
          value = self[name]
          next if value.is_a?(String)
          next if value.blank? && format[:allow_blank]

          errors.add(:base, format[:message] || "#{name.to_s.titleize} must be a string")
        end
      end

      # Add a format validator that ensures the value of `name`
      # matches the provided regex pattern when present. Respects
      # `allow_blank` to skip validation on empty values, and uses
      # a custom error message if supplied. Attached as an instance-
      # level `validate` block on the declaring class.
      def self.validate_format(klass, name, **options)
        format = options[:format] || {}
        return unless format[:with].present?

        klass.validate do
          value = self[name]
          next if value.blank? && format[:allow_blank]
          next if value.to_s.match(format[:with])

          message = format[:message]
          message ||= "#{name.to_s.titleize} invalid format"
          errors.add(:base, message)
        end
      end

      # Add a validator that ensures the value of `name`
      # is included in the provided `any_of` list. Respects
      # `allow_blank` to skip validation on empty values,
      # and uses a custom error message if supplied.
      # rubocop:disable Metrics/MethodLength
      def self.validate_any_of_values(klass, name, **options)
        values = options[:any_of]
        return if values.blank?

        format = options[:format] || {}
        klass.validate do
          value = self[name]
          next if values.include?(value)
          next if value.blank? && format[:allow_blank]

          message = format[:message]
          message ||= "#{name.to_s.titleize} invalid value: must be one of #{values.join(", ")}"
          errors.add(:base, message)
        end
      end
      # rubocop:enable Metrics/MethodLength

      # Add a length validator that ensures the value of `name`
      # meets optional `minimum` and `maximum` length constraints.
      # Provides default error messages unless custom ones are supplied.
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
      def self.validate_length(klass, name, length)
        klass.validate do
          value = self[name]
          next if value.nil?

          length_value = value.to_s.length
          too_short = length[:minimum] && length_value < length[:minimum]
          too_long = length[:maximum] && length_value > length[:maximum]

          too_short_error = length[:too_short]
          too_short_error ||=
            "#{name.to_s.titleize} is too short (minimum is #{length[:minimum]} characters)"
          errors.add(:base, too_short_error) if too_short

          too_long_error = length[:too_long]
          too_long_error ||=
            "#{name.to_s.titleize} is too long (maximum is #{length[:maximum]} characters)"
          errors.add(:base, too_long_error) if too_long
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
