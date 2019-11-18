# frozen_string_literal: true

class AdminSerializer < ActiveModel::Serializer
  attribute :id
  attribute :count_unread_issues, if: :for_channel?
  attribute :count_running_jobs, if: :for_channel?
  attribute :count_active_downloads, if: :for_channel?

  def for_channel?
    @for_channel ||= instance_options[:for_channel]
  end
end
