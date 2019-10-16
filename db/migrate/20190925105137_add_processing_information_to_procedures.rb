# frozen_string_literal: true

class AddProcessingInformationToProcedures < ActiveRecord::Migration[5.2]
  def change
    change_table :procedures, bulk: true do |t|
      t.references :processing_by, foreign_key: { to_table: :admins }
      t.datetime :processing_at
      t.datetime :priorized_at
      t.integer :lock_version, :integer, default: 0, null: false
    end
  end
end
