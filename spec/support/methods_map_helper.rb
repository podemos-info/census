# frozen_string_literal: true

module MethodsMapHelper
  def methods_map(object, methods)
    methods.map { |method| [method, object.send(method)] } .to_h
  end
end

RSpec.configure do |config|
  config.include MethodsMapHelper
end
