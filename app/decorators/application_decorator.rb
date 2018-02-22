# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  def type_name
    I18n.t("activerecord.models.#{object.class.to_s.underscore}.one")
  end

  def last_versions
    @last_versions ||= VersionableLastVersions.for(object).decorate
  end

  def count_versions
    @count_versions ||= VersionableCountVersions.for(object)
  end
end
