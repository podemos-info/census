# frozen_string_literal: true

class AddExternalIdsToPeople < ActiveRecord::Migration[5.1]
  def change
    remove_column :people, :extra, :jsonb

    add_column :people, :external_ids, :jsonb, default: {}
    add_index :people, "external_ids jsonb_path_ops", name: "index_people_on_external_ids", using: :gin
  end
end
