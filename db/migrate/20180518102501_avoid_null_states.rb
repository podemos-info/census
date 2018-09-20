# frozen_string_literal: true

class AvoidNullStates < ActiveRecord::Migration[5.2]
  def up
    change_nullables false
  end

  def down
    change_nullables true
  end

  def change_nullables(nullable)
    change_column :orders, :state, :string, null: nullable
    change_column :procedures, :state, :string, null: nullable

    change_table :people, bulk: true do |t|
      t.change :state, :integer, null: nullable
      t.change :verification, :integer, null: nullable
      t.change :membership_level, :integer, null: nullable
    end
  end
end
