# frozen_string_literal: true

class AttachmentDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def view_path
    helpers.view_attachment_procedure_path(id: object.procedure.id, attachment_id: object.id)
  end
end