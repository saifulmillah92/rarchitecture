# frozen_string_literal: true

module Input
  module Validators
    # Common
    #
    # Centralized helpers used by validator modules. This module keeps
    # shared behavior in one place so individual validator modules can
    # remain small and focused. Responsibilities include:
    # - Formatting ActiveModel error objects into user-friendly messages.
    # - Registering default attribute values on declaring classes.
    # - Recording nested input classes for `hash` and `array` validators.
    # - Resolving constant references passed via `from:` options.
    # - Providing reusable length validators for strings and numeric-like values.
    module Common
      # Apply common option handling for a validator attribute.
      # This helper centralizes setup so individual validators stay small:
      # - Registers a default value if `:default` is provided.
      # - Adds a blankness check based on `:allow_blank`.
      # - Attaches a length validator if `:min` or `:max` are given.
      def self.handle_options(klass, name, **options)
        add_default(klass, name, options[:default])
        allow_blank(klass, name, allow: options[:allow_blank] || true)
        validate_any_of_values(klass, name, options[:any_of] || [])
        validate_length(klass, name, options[:min], options[:max])
      end

      # Format an `ActiveModel::Error` into a human-readable string.
      # Prefers a custom `:message` option when present, otherwise falls
      # back to a friendly default for `:blank`, or the error type.
      def self.format_error_message(error)
        raw = error.options[:message]
        return raw.to_s if raw && !raw.to_s.empty?

        error.type == :blank ? "can't be blank" : error.type.to_s
      end

      # Register a default value for `name` on `klass`. Defaults are
      # stored in an `@defaults` instance variable on the class so that
      # they can be applied lazily at instance validation time.
      def self.add_default(klass, name, value)
        unless klass.instance_variable_defined?(:@defaults)
          klass.instance_variable_set(:@defaults, {})
        end

        defaults = klass.instance_variable_get(:@defaults)
        defaults[name] ||= value unless value.blank?
      end

      # Record a nested Input class for an array attribute. The entry is
      # stored on the owning class under `@nested_array_classes` keyed by
      # the attribute name so validation and transformation can locate it.
      def self.add_nested_array_class(klass, name, nested_klass)
        unless klass.instance_variable_defined?(:@nested_array_classes)
          klass.instance_variable_set(:@nested_array_classes, {})
        end

        klass.instance_variable_get(:@nested_array_classes)[name] = nested_klass
      end

      # Record a nested Input class for a hash attribute. Stored on the
      # declaring class under `@nested_classes` keyed by attribute name.
      def self.add_nested_class(klass, name, nested_klass)
        unless klass.instance_variable_defined?(:@nested_classes)
          klass.instance_variable_set(:@nested_classes, {})
        end

        klass.instance_variable_get(:@nested_classes)[name] = nested_klass
      end

      # Resolve a constant reference passed to the DSL. Accepts either a
      # `Class` object or a constant name (String or Symbol). Returns the
      # class or nil if it cannot be resolved.
      def self.resolve_const(name)
        return nil if name.nil?
        return name if name.is_a?(Class)

        Object.const_get(name)
      rescue NameError
        nil
      end

      # Attach an ActiveModel-style length validator to `klass` for the
      # attribute `name`. Provided as a helper so the `string` validator
      # can remain small. `min` and `max` are optional.
      # rubocop:disable Metrics/CyclomaticComplexity
      def self.validate_length(klass, name, min, max)
        return unless min || max

        klass.validate do
          value = self[name]
          next if value.nil?

          length = value.to_s.length
          too_short = min && length < min
          too_long = max && length > max

          errors.add(name, "is too short (minimum is #{min})") if too_short
          errors.add(name, "is too long (maximum is #{max})") if too_long
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      # Attach a validator that ensures the attribute `name` has a value
      # included in the given `values` list. Adds an error if the value
      # is not one of the allowed options.
      def self.validate_any_of_values(klass, name, values)
        return if values.blank?

        klass.validate do
          next if values.include?(self[name])

          errors.add(name, "invalid value: must be one of #{values.join(", ")}")
        end
      end

      # Attach a validator that enforces blankness rules for the attribute
      # `name`. If `allow` is false and the value is blank, adds a "can't
      # be blank" error. If `allow` is true, blank values are permitted.
      def self.allow_blank(klass, name, allow: true)
        klass.validate do
          value = self[name]
          next if allow
          next unless value.blank?

          errors.add(name, "can't be blank")
        end
      end
    end
  end
end
