# frozen_string_literal: true

require_relative "rarchitecture/version"

if defined?(Rails)
  require "rails"
  require "rails/generators"
end

Dir[File.join(__dir__, "rarchitecture", "**", "*.rb")].each do |file|
  require file
end

module RArchitecture
  class Error < StandardError; end
end
