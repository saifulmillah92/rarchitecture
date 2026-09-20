# frozen_string_literal: true

require_relative "../base"

module Rarchitecture
  module Generators
    class PresenterGenerator < Rarchitecture::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def ensure_application_presenter_and_continue
        presenter_path = Rails.root.join("app/presenters/application_presenter.rb")
        return if File.exist?(presenter_path)

        say_status :missing, missing_application_presenter, :yellow
        generate "rarchitecture:init for=presenter"
      end

      def create_presenter_file
        presenter_path = Rails.root.join("app/presenters", path, "#{name}_presenter.rb")
        return template "presenter.rb.tt", presenter_path unless modules.present?

        template "presenter_module.rb.tt", presenter_path
      end

      private

      def missing_application_presenter
        "application_presenter.rb not found. Running init generator..."
      end
    end
  end
end
