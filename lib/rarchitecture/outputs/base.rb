# frozen_string_literal: true

#
# Outputs::Base
#
# Base output for API responses. Provides a consistent JSON structure
# with status codes, messages, and a root key (`:data` by default).
#
# Responsibilities:
# - Wraps objects into API-friendly JSON.
# - Handles error detection and formatting.
# - Provides overridable `basic_format` and `detailed_format` methods for subclasses.
#
# Usage:
#   Outputs::Base.new(user).root_json
#   # => { code: 200, message: "ok", data: { id: 1, email: "..." } }
#

require "rack/utils"
require_relative "../core_ext/array"
require_relative "../core_ext/hash"

module Outputs
  class Base
    attr_reader :object, :options

    def self.array(models, **)
      Outputs::Array.new(models, **, item_output: self)
    end

    def initialize(object, options = {})
      @object  = object
      @options = options
      @options[:status] = Rack::Utils.status_code(options[:status] || 200)
      @options[:message] ||= "OK"
    end

    def root_json
      return error_format if error?

      as_root_json
    end

    def as_root_json
      { code: options[:status], message: options[:message], data: as_json }
    end

    def as_json(*)
      return nil if object.nil?

      send(output_method).as_json(*)
    end

    def to_json(*)
      return nil if object.nil?

      send(output_method).to_json(*)
    end

    def as_struct
      return nil if object.nil?

      send(output_method).as_struct
    end

    def status
      Rack::Utils.status_code(error? ? error_status : options[:status])
    end

    def error? = @object.respond_to?(:errors) && @object.errors.any?

    def error_format
      Outputs::Error.new(@object, status: error_status)
    end

    def output_method
      method = options[:use] || :basic_format
      method = :error_format if error?

      method
    end

    def basic_format = @object.as_json
    def detailed_format = basic_format
    def error_status = Outputs::Error.new(@object).status
  end
end
