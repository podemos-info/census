# frozen_string_literal: true

class Attachment < ApplicationRecord
  mount_uploader :file, AttachmentUploader
  belongs_to :procedure

  def image?
    content_type.to_s.start_with? "image"
  end
end
