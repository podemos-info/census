# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  def type_name
    model_name = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(object.model_name.to_s))
    I18n.t("activerecord.models.#{object.class.to_s.underscore.split("/").first}.#{model_name}.one")
  end
end
