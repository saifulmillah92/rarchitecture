# frozen_string_literal: true

require "action_controller"

class UsersController < Rarchitecture::ApplicationController::VIEW
  prepend_view_path File.expand_path("../../views", __dir__)

  def service
    @service ||= Rarchitecture::ApplicationService.new(model: model)
  end

  def model
    User
  end
end
