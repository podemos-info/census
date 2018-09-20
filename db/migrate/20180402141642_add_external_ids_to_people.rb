# frozen_string_literal: true

class AddExternalIdsToPeople < ActiveRecord::Migration[5.1]
  def up
    change_table :people, bulk: true do |t|
      t.remove :extra, :jsonb

      t.jsonb :external_ids, default: {}
      t.index "external_ids jsonb_path_ops", name: "index_people_on_external_ids", using: :gin
    end
  end

  def down
    change_table :people, bulk: true do |t|
      t.remove_index "external_ids jsonb_path_ops"
      t.remove :external_ids

      t.jsonb :extra, default: {}, null: false
    end
  end
end
