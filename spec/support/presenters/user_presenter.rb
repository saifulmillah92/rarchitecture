# frozen_string_literal: true

class UserPresenter < Rarchitecture::ApplicationPresenter
  def presentation
    { id: object.id, name: object.name, email: object.email }
  end

  def mini_presentation
    { id: object.id, email: object.email }
  end
end
