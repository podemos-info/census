# frozen_string_literal: true

class RemoveFlagsFromPerson < ActiveRecord::Migration[5.1]
  def change
    remove_column :people, :flags, :integer
  end
end
