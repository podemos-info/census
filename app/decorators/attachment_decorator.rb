# frozen_string_literal: true

class AttachmentDecorator < Draper::Decorator
  delegate_all

  def view_path(options = {})
    version = options[:version]
    helpers.view_attachment_procedure_path(id: object.procedure.id, attachment_id: object.id, version: version)
  end

  def image?
    object.content_type.to_s.start_with? "image"
  end
end
