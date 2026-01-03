# frozen_string_literal: true

require_relative "../base"

module Rarchitecture
  module Generators
    class InputGenerator < Rarchitecture::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def ensure_application_input_and_continue
        repo_path = Rails.root.join("app/inputs/application_input.rb")
        return if File.exist?(repo_path)

        say_status :missing, missing_application_input, :yellow
        generate "rails_architecture:init for=input"
      end

      def create_input_creation_file
        input_path = Rails.root.join("app/inputs", path, "#{name}_creation_input.rb")
        return template "input.rb.tt", input_path unless modules.present?

        template "input_module.rb.tt", input_path
      end

      def create_input_update_file
        input_path = Rails.root.join("app/inputs", path, "#{name}_update_input.rb")
        return template "input_update.rb.tt", input_path unless modules.present?

        template "input_update_module.rb.tt", input_path
      end

      private

      def missing_application_input
        "application_input.rb not found. Running init generator..."
      end
    end
  end
end
