# frozen_string_literal: true

ActiveAdmin::Views::Pages::Base.class_eval do
  alias_method :old_body_classes, :body_classes
  def body_classes
    ret = old_body_classes
    ret << controller.extra_body_class if controller.respond_to?(:extra_body_class) && controller.extra_body_class
    ret
  end
end
