# frozen_string_literal: true

class TestCommand < Rectify::Command
  include Wisper::Publisher
end

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
