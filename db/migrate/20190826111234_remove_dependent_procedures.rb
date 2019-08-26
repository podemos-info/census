# frozen_string_literal: true

class RemoveDependentProcedures < ActiveRecord::Migration[5.2]
  def change
    remove_reference :procedures, :depends_on, foreign_key: { to_table: :procedures }
  end
end
