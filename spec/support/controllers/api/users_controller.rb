# frozen_string_literal: true

require "action_controller"

module Api
  class UsersController < RArchitecture::ApplicationController::API
    # Rails 8 ActionController::API is very stripped down.
    # Including these modules provides the 'dispatch' and 'request' methods
    # that RSpec and the Rails Router expect.
    include ActionController::Rendering
    include ActionController::MimeResponds

    # In Rails 8, if your base class is missing 'dispatch',
    # this ensures the controller can be called by the router.
    def dispatch(name, request, response)
      set_request!(request)
      set_response!(response)
      process(name)
      to_a
    end

    private

    def service
      @service ||= RArchitecture::ApplicationService.new(model: model)
    end

    def model
      User
    end
  end
end
