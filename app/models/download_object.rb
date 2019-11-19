# frozen_string_literal: true

class DownloadObject < ApplicationRecord
  belongs_to :download
  belongs_to :object, polymorphic: true
end
