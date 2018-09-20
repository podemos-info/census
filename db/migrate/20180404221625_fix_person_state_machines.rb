# frozen_string_literal: true

class FixPersonStateMachines < ActiveRecord::Migration[5.1]
  def up
    change_table :people, bulk: true do |t|
      t.remove :membership_level
      t.remove :verifications

      t.integer :verification
      t.integer :membership_level
    end
  end

  def down
    change_table :people, bulk: true do |t|
      t.remove :membership_level
      t.remove :verification

      t.integer :verifications
      t.string :membership_level
    end
  end
end
