# frozen_string_literal: true

class AvoidNullStates < ActiveRecord::Migration[5.2]
  def change
    change_column :orders, :state, :string, null: false
    change_column :people, :state, :integer, null: false
    change_column :people, :verification, :integer, null: false
    change_column :people, :membership_level, :integer, null: false
    change_column :procedures, :state, :string, null: false
  end
end
