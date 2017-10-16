# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  def type_name
    model_name = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(object.model_name.to_s))
    I18n.t("activerecord.models.#{object.class.to_s.underscore.split("/").first}.#{model_name}.one")
  end

  def format_ip(object)
    object.is_a?(Hash) ? IPAddr.new(object["addr"], object["family"]) : object
  end

  def last_versions
    @last_versions ||= VersionableLastVersions.for(object).decorate
  end

  def count_versions
    @count_versions ||= VersionableCountVersions.for(object)
  end
end
