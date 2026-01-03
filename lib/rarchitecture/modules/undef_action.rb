# frozen_string_literal: true

module UndefAction
  extend ActiveSupport::Concern

  def self.prepended(base)
    base.singleton_class.prepend(ClassMethods)
  end

  module ClassMethods
    def undef_action(*method_names)
      method_names.each do |name|
        define_method(name) do |*|
          raise Rarchitecture::ApplicationService::NoMethodError, "The '#{name}' action not found."
        end
      end
    end
  end
end
