# frozen_string_literal: true

class JobMessageDecorator < ApplicationDecorator
  decorates "active_job_reporter/job_message"

  delegate_all

  def created_at
    object.created_at.to_s(:short)
  end

  def message
    if object.message[:key]
      I18n.t("census.jobs.job_messages.#{object.message[:key]}")
    else
      object.message[:raw]
    end
  end

  def related
    object.message[:related]&.map do |gid|
      obj = GlobalID.find(gid)&.decorate
      if obj
        h.link_to obj.name, h.url_for(obj)
      else
        gid
      end
    end&.to_sentence&.html_safe
  end
end
