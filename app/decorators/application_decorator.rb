# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  def type_name
    I18n.t("activerecord.models.#{object.class.to_s.underscore}.one")
  end

  def name_link
    if can? :show
      h.link_to name, h.url_for(self)
    else
      name
    end
  end

  def last_versions
    @last_versions ||= VersionableLastVersions.for(object).decorate(context: context)
  end

  def count_versions
    @count_versions ||= VersionableCountVersions.for(object)
  end

  def last_version_classed_changeset
    @last_version_classed_changeset ||= begin
      version = object.versions.last
      if version&.event == "update"
        classed_changeset(version.object_changes.keys, "version_change")
      else
        {}
      end
    end
  end

  def can?(action)
    Pundit.policy(context[:current_admin] || h.current_admin, self).send("#{action}?")
  end

  protected

  def classed_changeset(changed_attributes, classes)
    Hash[changed_attributes.map { |attribute| [attribute.to_sym, classes] }]
  end

  def sensible_data
    if can? :show
      yield
    else
      I18n.t("census.messages.protected_data")
    end
  end

  class << self
    def sensible_fields(*fields)
      fields.each do |field|
        define_method field do
          sensible_data do
            object.send(field)
          end
        end
      end
    end
  end
end
