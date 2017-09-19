# frozen_string_literal: true

class Attachment < ApplicationRecord
  mount_uploader :file, AttachmentUploader
  belongs_to :procedure
end
