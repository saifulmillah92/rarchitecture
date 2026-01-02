# frozen_string_literal: true

require "action_controller"

class UsersController < RArchitecture::ApplicationController::VIEW
  prepend_view_path File.expand_path("../../views", __dir__)

  def service
    @service ||= RArchitecture::ApplicationService.new(model: model)
  end

  def model
    User
  end
end
