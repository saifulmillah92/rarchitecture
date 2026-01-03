# frozen_string_literal: true

require_relative "../../base"

module Rarchitecture
  module Generators
    module Controller
      class ViewGenerator < Rarchitecture::Generators::Base
        source_root File.expand_path("templates", __dir__)
        class_option :message, type: :boolean, default: true
        class_option :service_exist, type: :boolean, default: false

        def create_controller_file
          filename = "#{name.pluralize}_controller.rb"
          controller_path = Rails.root.join("app/controllers", path, filename)
          return template "controller.rb.tt", controller_path unless modules.present?

          template "controller_module.rb.tt", controller_path
        end

        def create_view_files
          template "index.rb.tt", filepath("index.html.erb")
          template "new.rb.tt", filepath("new.html.erb")
          template "edit.rb.tt", filepath("edit.html.erb")
        end

        def add_routes
          inject_into_file routes_path, before: /^end\n/ do
            "\n#{indent(routes_block, 2)}"
          end
        end

        def final_message
          return unless options[:message]

          say "🎉 Endpoint generated successfully!"
          say "Test it instantly:"
          say "curl -X GET http://localhost:3000/#{endpoint}"
        end

        private

        def filepath(filename)
          Rails.root.join("app/views", path, name.pluralize, filename)
        end

        def routes_path
          "config/routes.rb"
        end

        def routes_content
          File.read(routes_path)
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
            resources :#{name.pluralize}, only: [ :index, :show, :create, :update, :destroy, :new, :edit ]
            # -------------------------------------------------
          RUBY
        end

        # rubocop:disable Metrics/MethodLength
        def routes_block_modules
          inner = <<~RUBY
            resources :#{name.pluralize}, only: [ :index, :show, :create, :update, :destroy, :new, :edit ]
          RUBY

          # Wrap recursively
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

        def missing_application_controller
          "application_controller.rb not found. Running init generator..."
        end
      end
    end
  end
end
