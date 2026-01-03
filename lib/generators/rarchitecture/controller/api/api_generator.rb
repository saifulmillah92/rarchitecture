# frozen_string_literal: true

require_relative "../../base"

module Rarchitecture
  module Generators
    module Controller
      class ApiGenerator < Rarchitecture::Generators::Base
        source_root File.expand_path("templates", __dir__)
        class_option :message, type: :boolean, default: true
        class_option :service_exist, type: :boolean, default: false
        class_option :output_exist, type: :boolean, default: false

        def ensure_application_controller_and_continue
          repo_path = Rails.root.join("app/controllers/api/application_controller.rb")
          return if File.exist?(repo_path)

          say_status :missing, missing_application_controller, :yellow
          template "api_controller.rb.tt", "app/controllers/api/application_controller.rb"
        end

        def create_controller_file
          filename = "#{name.pluralize}_controller.rb"
          controller_path = Rails.root.join("app/controllers/api", path, filename)
          return template "controller.rb.tt", controller_path unless modules.present?

          template "controller_module.rb.tt", controller_path
        end

        # rubocop:disable Layout/HeredocIndentation, Metrics/MethodLength, Performance/StringInclude
        def add_routes
          if routes_content.match?(/scope :api, module: :api do/)
            return if routes_content.match?(/resources\s+:#{name.pluralize}\s/)

            inject_into_file routes_path, after: /scope :api, module: :api do\n/ do
              "#{indent(routes_block, 4)} \n"
            end
          else
            inject_into_file routes_path, before: /^end\n/ do
              <<~RUBY

                scope :api, module: :api do
              #{indent(routes_block.chomp, 4)}
                end
              RUBY
            end
          end
        end
        # rubocop:enable Layout/HeredocIndentation, Metrics/MethodLength, Performance/StringInclude

        def final_message
          return unless options[:message]

          say "🎉 Endpoint generated successfully!"
          say "Test it instantly:"
          say "curl -X GET http://localhost:3000/api/#{endpoint}"
        end

        private

        def routes_path
          "config/routes.rb"
        end

        def routes_content
          File.read(Rails.root.join(routes_path))
        end

        def indent(lines, spaces)
          lines.lines.map { |line| (" " * spaces) + line }.join
        end

        def routes_block
          return routes_block_modules if modules.present?

          <<~RUBY
            # -------------------------------------------------
            # Auto-generated routes for #{class_name.pluralize}
            # -------------------------------------------------
            resources :#{name.pluralize}
            # -------------------------------------------------
          RUBY
        end

        # rubocop:disable Metrics/MethodLength
        def routes_block_modules
          inner = <<~RUBY
            resources :#{name.pluralize}
          RUBY

          modules.reverse_each do |ns|
            inner = <<~RUBY
              namespace :#{ns.downcase} do
                #{inner.strip}
              end
            RUBY
          end

          <<~RUBY
            # -------------------------------------------------
            # Auto-generated routes for #{class_name.pluralize}
            # -------------------------------------------------
            #{inner.strip}
            # -------------------------------------------------
          RUBY
        end
        # rubocop:enable Metrics/MethodLength

        def endpoint
          return name.pluralize if modules.blank?

          "#{modules.map(&:downcase).join("/")}/#{name.pluralize}"
        end

        def service_exist?
          return true if options["service_exist"]

          class_exists?("#{class_name}Service")
        rescue NameError
          false
        end

        def output_exist?
          return true if options["output_exist"]

          class_exists?("#{class_name}Presenter")
        rescue NameError
          false
        end

        def missing_application_controller
          "application_controller.rb not found. Running init generator..."
        end
      end
    end
  end
end
