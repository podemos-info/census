# frozen_string_literal: true

class Download < ApplicationRecord
  mount_uploader :file, DownloadUploader
  belongs_to :person
end
