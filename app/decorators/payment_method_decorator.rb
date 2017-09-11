# frozen_string_literal: true

class PaymentMethodDecorator < Draper::Decorator
  delegate_all

  decorates_association :person

  def type_name
    I18n.t("activerecord.models.payment_methods.#{ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(object.model_name.to_s))}.one")
  end
end
