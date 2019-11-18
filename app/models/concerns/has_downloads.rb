# frozen_string_literal: true

module HasDownloads
  extend ActiveSupport::Concern

  included do
    has_many :download_objects, as: :object, dependent: :destroy, inverse_of: :object
    has_many :downloads, -> { distinct }, through: :download_objects
  end
end
