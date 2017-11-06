# frozen_string_literal: true

class Download < ApplicationRecord
  include Issuable

  mount_uploader :file, DownloadUploader
  belongs_to :person
end
