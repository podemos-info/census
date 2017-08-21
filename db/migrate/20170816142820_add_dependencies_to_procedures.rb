class AddDependenciesToProcedures < ActiveRecord::Migration[5.1]
  def change
    add_reference :procedures, :depends_on, foreign_key: { to_table: :procedures }
  end
end
