# frozen_string_literal: true

require "rspec/json_expectations"
require "pry"
require "rails/all"
require "bundler/setup"
require "active_support"
require "active_support/concern"
require "active_support/core_ext"
require "rails"
require "action_controller/railtie"
require "rails-controller-testing"
require "rspec/rails"
require "ammeter/init"

Dir[File.join(__dir__, "../lib/rarchitecture", "**", "*.rb")].each do |file|
  require file
end

Dir[File.join(__dir__, "../spec/support", "**", "*.rb")].each do |file|
  require file
end

class TestApp < Rails::Application
  config.eager_load = false
  config.hosts.clear
  config.active_support.to_time_preserves_timezone = :zone
end

TestApp.initialize!

Sortable.module_eval do
  def filter_by_sort_column(sort_column)
    if sort_column.present?
      validate_column = @scope.column_names.include?(sort_column.to_s)

      invalid = ActiveModel::StrictValidationFailed
      error_message = "Column #{sort_column} does not exist"
      raise invalid, error_message unless validate_column
    end

    @scope.reorder(sort_column, @options.with_indifferent_access[:sort_direction])
  end
end

Rarchitecture::ApplicationService.module_eval do
  def create(attrs = {})
    model.create(attrs)
  end

  def update(id, attrs = {})
    record = find(id)
    record.update(**attrs)

    record
  end

  def destroy(id)
    record = find(id)
    record.destroy!
    record
  end
end

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.formatter = :documentation
  config.full_backtrace = true

  config.define_derived_metadata(file_path: %r{spec/lib/generators}) do |metadata|
    metadata[:type] = :generator
  end

  # This allows the use of `render_views` in your specs
  config.include RSpec::Rails::ControllerExampleGroup, type: :controller

  # This provides the 'setup' method expected by rails-controller-testing
  config.include Rails::Controller::Testing::TestProcess, type: :controller
  config.include Rails::Controller::Testing::TemplateAssertions, type: :controller
  config.include Rails::Controller::Testing::Integration, type: :controller

  # For your request specs specifically
  config.include Rails::Controller::Testing::Integration, type: :request
end
