# frozen_string_literal: true

#
# Outputs::Error
#
# Output for error responses. Wraps validation errors or custom messages
# into a consistent JSON structure with `error: { code, message }`.
#
# Usage:
#   Outputs::Error.new(user).as_json
#   # => { error: { code: 422, message: "Email can't be blank" } }
#
module Outputs
  class Error
    attr_reader :options

    def initialize(object, options = {})
      @object  = object
      @options = options
      @options[:status] ||= 422
    end

    def as_json(*)
      { error: { code: status, message: error_message } }
    end

    def root_json = as_json
    def error?    = true

    def error_message
      if @object.respond_to?(:errors)
        @object.errors.to_a.first
      elsif @object.is_a?(String) || @object.is_a?(Hash) || @object.is_a?(::Array)
        @object
      else
        raise TypeError, "Unrecognized object for #{self.class}"
      end
    end

    def status = Rack::Utils.status_code(options[:status])
  end
end
