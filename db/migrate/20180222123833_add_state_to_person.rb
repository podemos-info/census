# frozen_string_literal: true

class AddStateToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :state, :integer
  end
end
