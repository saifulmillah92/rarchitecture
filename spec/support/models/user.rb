# frozen_string_literal: true

require_relative "model"

class User < Model
  attribute :id, :integer
  attribute :name, :string
  attribute :email, :string

  validates :email, presence: true, format: { with: /\A.+@.+\..+\z/ }
end
