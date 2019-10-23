# frozen_string_literal: true

class AddPrioritizedAtToProcedures < ActiveRecord::Migration[5.2]
  def change
    add_column :procedures, :prioritized_at, :datetime

    add_index :procedures, :prioritized_at
  end
end
