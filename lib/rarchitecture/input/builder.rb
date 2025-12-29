# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require_relative "validators/string"
require_relative "validators/number"
require_relative "validators/array"
require_relative "validators/hash"
require_relative "validators/bool"
require_relative "validators/common"

module Input
  # Builder is the fluent object returned by `optional(:name)` / `required(:name)`.
  #
  # Responsibilities:
  # - Attach type validators to the owning input class.
  # - Support nested `hash` and nested `array` definitions via blocks or `from:` option.
  # - Register default values on the owning class.
  #
  # Usage:
  #   optional(:email).string(default: "saiful@example.com")
  #   required(:roles).array do
  #     required(:title).string
  #   end
  class Builder
    # klass - the input class that declared the key
    # name  - the key name (symbol)
    def initialize(klass, name)
      @klass = klass
      @name = name
    end

    # Define a string attribute. Delegates to StringValidation module.
    def string(**)
      Input::Validators::StringValidation.attach(@klass, @name, **)
      self
    end

    # Define a numeric attribute. Delegates to NumberValidation module.
    def number(**)
      Input::Validators::NumberValidation.attach(@klass, @name, **)
      self
    end

    # Define an array attribute. Delegates to ArrayValidation module.
    def array(**options, &)
      options[:nested_klass] = build_nested_klass(&)
      Input::Validators::ArrayValidation.attach(@klass, @name, **options)
      self
    end

    # Define a hash attribute. Delegates to HashValidation when nested or from: provided.
    def hash(**options, &)
      options[:nested_klass] = build_nested_klass(&)
      Input::Validators::HashValidation.attach(@klass, @name, **options)
      self
    end

    # Define a boolean attribute. Delegates to BoolValidation module.
    def bool(default: nil, **)
      Input::Validators::BoolValidation.attach(@klass, @name, default: default, **)
      self
    end

    def any_of(values, **options)
      options[:any_of] = values
      Input::Validators::StringValidation.attach(@klass, @name, **options)
    end

    private

    def build_nested_klass(&)
      return unless block_given?

      nested_klass = Class.new { include Input }
      nested_klass.class_eval(&)
      nested_klass
    end
  end
end
