# frozen_string_literal: true

require "rarchitecture"
require "pry"

Dir[File.join(__dir__, "../lib/rarchitecture", "**", "*.rb")].each do |file|
  require file
end

Dir[File.join(__dir__, "../spec/support", "**", "*.rb")].each do |file|
  require file
end

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
