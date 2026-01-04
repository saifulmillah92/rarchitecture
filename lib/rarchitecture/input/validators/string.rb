# frozen_string_literal: true

require_relative "common"

module Input
  module Validators
    # StringValidation
    #
    # Responsibilities:
    # - Ensure an attribute value is a String when present.
    # - Optionally enforce minimum/maximum length constraints.
    # - Register a default value on the declaring class when provided.
    # - Support format validation with regex, custom messages, and blank allowance.
    #
    # Usage examples:
    #   optional(:name).string
    #   required(:code).string(length: { minimum: 3, maximum: 10 })
    #
    # For more detailed usage and edge cases, see `input_spec.rb`.
    #
    # Options:
    # - default: sets a default string value on the declaring class.
    # - format:
    #     :with        => regex pattern to match
    #     :message     => custom error message
    #     :allow_blank => allow empty values without error
    # - any_of: restricts values to a given list
    # - length:
    #     :minimum   => minimum allowed length
    #     :maximum   => maximum allowed length
    #     :too_short => custom error message when below minimum
    #     :too_long  => custom error message when above maximum
    module StringValidation
      # Attach string validations to `klass` for the attribute `name`.
      # Accepts `default`, `format`, `any_of`, and `length` options.
      # Additional options are ignored to keep the API forward-compatible.
      def self.attach(klass, name, **options)
        add_string_type_check(klass, name, **options)
        Common.add_default(klass, name, options[:default])

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

        Common.with_value(klass, name, format) do |value, record, message|
          next if value.is_a?(String)

          record.errors.add(:base, message || "#{name.to_s.titleize} must be a string")
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

        Common.with_value(klass, name, format) do |value, record, message|
          next if value.to_s.match(format[:with])

          record.errors.add(:base, message || "#{name.to_s.titleize} invalid format")
        end
      end

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
          too_long  = length[:maximum] && length_value > length[:maximum]

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
