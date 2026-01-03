# frozen_string_literal: true

require "rails/generators"

module Rarchitecture
  module Generators
    class InitGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      class_option :api, type: :boolean, default: false
      class_option :view, type: :boolean, default: false
      class_option :for, type: :string, default: "all"

      def create_application_repository
        return unless options[:for].in?(["all", "repositoy"])

        template "application_repository.rb.tt",
                 "app/repositories/application_repository.rb"
      end

      def create_application_service
        return unless options[:for].in?(["all", "service"])

        template "application_service.rb.tt", "app/services/application_service.rb"
      end

      def create_application_output
        return unless options[:for].in?(["all", "output"])

        template "application_output.rb.tt", "app/outputs/application_output.rb"
      end

      def create_application_input
        return unless options[:for].in?(["all", "input"])

        template "application_input.rb.tt", "app/inputs/application_input.rb"
      end

      def create_application_exception
        return unless options[:for].in?(["all", "exception"])

        template "application_exception.rb.tt", "app/lib/application_exception.rb"
      end

      def create_application_controller
        return unless options[:for].in?(["all", "controller"])

        api, view = resolve_controller_options

        filename = "application_controller.rb"
        template "api_controller.rb.tt", "app/controllers/api/#{filename}", force: true if api
        template "application_controller.rb.tt", "app/controllers/#{filename}", force: true if view
      end

      # rubocop:disable Metrics/MethodLength, Layout/LineLength
      def final_message
        say "\n🎉  Congratulations! Your Rarchitecture components have been successfully generated.", :green
        say "You are now ready to begin using them.\n"

        say "Quick start:", :yellow
        say <<-MSG

          - Open the generated files in your editor.
          - Review inline comments and examples.
          - Extend or override methods as needed for your domain.
          - Scaffold new components with:
              bin/rails g rarchitecture:init
              bin/rails g rarchitecture:arc ModelName
          - Replace "ModelName" with your model.

          For a full list of available commands:
              bin/rails g --help

          Happy coding! 🎉
        MSG
      end
      # rubocop:enable Metrics/MethodLength, Layout/LineLength

      private

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
      def resolve_controller_options
        return [true, false] if options[:api] && !options[:view]
        return [false, true] if options[:view] && !options[:api]
        return [true, true]  if options[:api] && options[:view]

        answer = ask(
          "Controllers to generate? 'api' (overwrites Api::ApplicationController), " \
          "'view' (overwrites ApplicationController), or 'both' (default: both)",
          default: "both",
        )

        case answer.downcase
        when "api"  then [true, false]
        when "view" then [false, true]
        else             [true, true]
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
    end
  end
end
