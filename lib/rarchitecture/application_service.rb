# frozen_string_literal: true

require_relative "modules/undef_action"
require_relative "application_repository"

module Rarchitecture
  class ApplicationService
    prepend UndefAction

    attr_reader :model, :user, :repository

    def initialize(model:, user: nil, repository: nil)
      super()

      @model = model
      @user  = user
      @repository = repository
      @repository ||= ApplicationRepository.new(model.all) if model.respond_to?(:all)
    end

    def all(includes: [], **query)
      assert_repository!
      repository.filter(query).include(*includes).limited.to_a
    end

    def find(id, includes: [])
      assert_repository!
      record = repository.include(*includes).get(id)
      assert! record.present?, on_error: "#{model.class_name} not found"

      record
    end

    def find_by(query = {})
      assert_repository!
      model.find_by(query)
    end

    def new(attrs = {})
      assert_repository!
      model.new(attrs)
    end

    def create(attrs = {})
      assert_repository!
      transaction do
        record = model.create!(attrs)
        record.reload
      end
    end

    def update(id, attrs = {})
      record = find(id)
      transaction do
        record.update!(**attrs)
        record.reload
      end
    end

    def destroy(id)
      record = find(id)
      transaction do
        record.destroy!
        record
      end
    end

    def count(params = {})
      assert_repository!
      repository.filter(params.except(:limit, :offset, :page)).count
    end

    def validate!(input)
      return input unless input
      raise ActiveRecord::RecordInvalid, input if input.errors.any? || !input.valid?

      input
    end

    def authorize!(*truths, on_error: "Not allowed")
      raise Unauthorized, on_error if truths.none?
    end

    def assert!(*truths, on_error: "Invalid")
      raise Invalid, on_error if truths.none?
    end

    def transaction(*, &)
      ActiveRecord::Base.transaction(*, &)
    end

    class Invalid < ::StandardError; end
    class Unauthorized < ::StandardError; end
    class NoMethodError < ::StandardError; end
    class ClassNotFoundError < ::StandardError; end
    class NotImplementedError < ::StandardError; end

    private

    def assert_repository!
      return if repository

      raise NotImplementedError, "#{model} does not support this action"
    end
  end
end
