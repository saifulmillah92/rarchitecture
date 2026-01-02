# frozen_string_literal: true

require_relative "exception_handler"

module Exceptions
  class VIEW < ActionView::Base
    include ExceptionHandler

    attr_reader :options

    # rubocop:disable Lint/MissingSuper
    def initialize(error, **options)
      @object = error
      @options = options

      options[:status] ||= 422
      options[:debug] = !Rails.env.production?
      options[:backtrace] = backtrace
    end
    # rubocop:enable Lint/MissingSuper

    def handle(controller)
      @controller = controller
      send(handler, @object)

      flash.alert = @message if flash
      return redirect_to request.referer, status: options[:status] if request.referer

      render "errors/index",
             locals: { message: @message, options: options },
             status: options[:status]
    end

    def redirect_to(path, **)
      @controller.redirect_to(path, **)
    end

    def request
      @request ||= @controller.request
    end

    def flash
      @controller.flash if @controller.respond_to?(:flash)
    end

    def render(path, **)
      @controller.render(path, **)
    end

    def exception(error)
      @message = "Sorry, there's an error on our side. We're working on it!"
      @message = error.message if options[:debug]
    end
  end
end
