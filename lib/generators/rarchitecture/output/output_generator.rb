# frozen_string_literal: true

require_relative "../base"

module Rarchitecture
  module Generators
    class OutputGenerator < Rarchitecture::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def ensure_application_output_and_continue
        repo_path = Rails.root.join("app/outputs/application_output.rb")
        return if File.exist?(repo_path)

        say_status :missing, missing_application_output, :yellow
        generate "rails_architecture:init for=output"
      end

      def create_output_file
        output_path = Rails.root.join("app/outputs", path, "#{name}_output.rb")
        return template "output.rb.tt", output_path unless modules.present?

        template "output_module.rb.tt", output_path
      end

      private

      def missing_application_output
        "application_output.rb not found. Running init generator..."
      end
    end
  end
end
