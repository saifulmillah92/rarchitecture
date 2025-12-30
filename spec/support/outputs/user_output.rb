# frozen_string_literal: true

class UserOutput < RArchitecture::ApplicationOutput
  def mini_format
    { id: @object.id, email: @object.email }
  end
end
