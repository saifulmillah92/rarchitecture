# frozen_string_literal: true

class UserOutput < Rarchitecture::ApplicationOutput
  def mini_format
    { id: @object.id, email: @object.email }
  end
end
