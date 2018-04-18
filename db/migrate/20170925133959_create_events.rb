# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.integer :visit_id

      # user
      t.references :admin

      t.string :name
      t.jsonb :properties
      t.timestamp :time
    end

    add_index :events, [:visit_id, :name]
    add_index :events, [:admin_id, :name]
    add_index :events, [:name, :time]
  end
end
