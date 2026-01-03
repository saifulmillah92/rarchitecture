# frozen_string_literal: true

require_relative "../base"

module Rarchitecture
  module Generators
    class ServiceGenerator < Rarchitecture::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def ensure_application_service_and_continue
        repo_path = Rails.root.join("app/services/application_service.rb")
        return if File.exist?(repo_path)

        say_status :missing, missing_application_service, :yellow
        generate "rails_architecture:init for=service"
      end

      def ensure_repository_and_continue
        repo_path = Rails.root.join("app/repositories", path, "#{name}_repository.rb")
        return if File.exist?(repo_path)

        say_status :missing, missing_repositories(repo_path), :yellow
        generate "rails_architecture:repository #{raw_name}"
      end

      def create_service_file
        service_path = Rails.root.join("app/services", path, "#{name}_service.rb")
        return template "service.rb.tt", service_path unless modules.present?

        template "service_module.rb.tt", service_path
      end

      private

      def missing_application_service
        "application_service.rb not found. Running init generator..."
      end

      def missing_repositories(repo_path)
        "#{repo_path} not found. Running repository generator..."
      end
    end
  end
end
