# frozen_string_literal: true

require_relative "application_repository"

module RArchitecture
  class ApplicationService
    attr_reader :model, :user, :repository

    def initialize(model:, user: nil, repository: nil)
      super()

      @model = model
      @user  = user
      @repository = repository
      @repository ||= ApplicationRepository.new(model.all)
    end

    def all(query = {}, includes: [])
      repository.filter(query).include(*includes).limited.to_a
    end

    def find(id, includes: [])
      record = repository.include(*includes).get(id)
      assert! record.present?, on_error: "#{model.class_name} not found"

      record
    end

    def find_by(query = {})
      model.find_by(query)
    end

    def new(attrs = {})
      model.new(attrs)
    end

    def create(attrs = {})
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
      repository.filter(params.except(:limit, :offset, :page)).count
    end

    def assert!(*truths, on_error: "Invalid")
      raise Invalid, on_error if truths.none?
    end

    def transaction(*, &)
      ActiveRecord::Base.transaction(*, &)
    end

    class Invalid < ::StandardError; end
    class ClassNotFoundError < ::StandardError; end
    class NotImplementedError < ::StandardError; end
  end
end
