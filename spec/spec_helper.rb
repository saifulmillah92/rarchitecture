# frozen_string_literal: true

require "rarchitecture"
require "pry"

Dir[File.join(__dir__, "../lib/rarchitecture", "**", "*.rb")].each do |file|
  require file
end

Dir[File.join(__dir__, "../spec/support", "**", "*.rb")].each do |file|
  require file
end

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

RArchitecture::ApplicationService.module_eval do
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
end
