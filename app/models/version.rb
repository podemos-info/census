# frozen_string_literal: true

class Version < ActiveRecord::Base
  include PaperTrail::VersionConcern

  belongs_to :item, polymorphic: true

  def update?
    event == "update"
  end
end
