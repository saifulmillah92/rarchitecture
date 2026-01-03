# frozen_string_literal: true

module Rarchitecture
  class Engine < ::Rails::Engine
    initializer "rails_architecture.add_view_paths" do
      views_path = File.expand_path("./views", __dir__)
      ActionController::Base.prepend_view_path(views_path)
    end
  end
end
