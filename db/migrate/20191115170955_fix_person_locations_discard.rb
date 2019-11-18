# frozen_string_literal: true

class FixPersonLocationsDiscard < ActiveRecord::Migration[5.2]
  def change
    rename_column :person_locations, :deleted_at, :discarded_at
  end
end
