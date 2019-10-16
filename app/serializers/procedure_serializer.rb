# frozen_string_literal: true

class ProcedureSerializer < ActiveModel::Serializer
  attributes :id, :type, :state, :information

  attribute :processing_by_id, if: :for_channel?
  attribute :processing_by_name, if: :for_channel?
  attribute :processing_at, if: :for_channel?

  def processing_by_name
    object&.processing_by&.name
  end

  def for_channel?
    @for_channel ||= instance_options[:for_channel]
  end
end
