# frozen_string_literal: true

class Version < ApplicationRecord
  include PaperTrail::VersionConcern

  belongs_to :item, polymorphic: true

  def update?
    event == "update"
  end
end
