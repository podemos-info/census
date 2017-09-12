# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  def type_name(model)
    I18n.t("activerecord.models.#{model.pluralize}.#{ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(object.model_name.to_s))}.one")
  end
end
