# frozen_string_literal: true

module RectifyCommandHelper
  def stub_command(clazz, signal, *published_event_args)
    stub_const(clazz, Class.new(TestCommand) do
      define_method(:call) do
        broadcast(signal, *published_event_args)
      end

      define_singleton_method(:call) do |*_args, &block|
        command = new
        command.evaluate(&block)
        command.call
      end
    end)
  end
end

class TestCommand < Rectify::Command
  include Wisper::Publisher
end

RSpec.configure do |config|
  config.include Rectify::RSpec::Helpers
  config.include RectifyCommandHelper
end
