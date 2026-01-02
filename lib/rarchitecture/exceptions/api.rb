# frozen_string_literal: true

require_relative "../outputs/error"
require_relative "exception_handler"

module Exceptions
  class API < Outputs::Error
    include ExceptionHandler

    def initialize(err, options = {})
      super

      render_exception
    end

    def as_json(*)
      super.merge(backtrace: backtrace).compact
    end

    def error_message = @message
    def namespace     = options[:namespace]

    private

    def render_exception
      send(handler, @object)
    end

    def exception(error)
      set_error 500, "Sorry, there's an error on our side. We're working on it!"
      @message = error.message if options[:debug]
    end
  end
end
