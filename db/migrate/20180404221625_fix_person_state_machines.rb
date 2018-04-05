# frozen_string_literal: true

class FixPersonStateMachines < ActiveRecord::Migration[5.1]
  def change
    remove_column :people, :membership_level, :string
    remove_column :people, :verifications, :integer

    add_column :people, :verification, :integer
    add_column :people, :membership_level, :integer
  end
end
