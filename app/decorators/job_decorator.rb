# frozen_string_literal: true

class JobDecorator < ApplicationDecorator
  delegate_all
  decorates_association :messages, with: JobMessageDecorator

  def name
    "#{job_type_name} ##{id}"
  end

  alias to_s name
  alias listable_name name

  def job_type_name
    I18n.t("census.jobs.types.#{object.job_type.underscore}")
  end

  def job_type_link
    h.link_to job_type_name, object
  end

  def status_name
    I18n.t("census.jobs.status.#{object.status}")
  end

  def result_name
    return "" unless object.result
    I18n.t("census.jobs.result.#{object.result}")
  end

  def objects_links
    object.job_objects.map do |job_object|
      obj = job_object.object&.decorate(context: context)
      if obj
        h.link_to obj.name, h.url_for(obj)
      else
        "#{job_object.object_type} ##{job_object.object_id}"
      end
    end.to_sentence.html_safe
  end
end
