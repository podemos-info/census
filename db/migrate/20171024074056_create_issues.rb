# frozen_string_literal: true

class CreateIssues < ActiveRecord::Migration[5.1]
  def change
    create_table :issues do |t|
      t.string :issue_type, null: false
      t.string :description
      t.integer :role
      t.integer :level, null: false

      t.belongs_to :assigned_to, foreign_key: { to_table: :people }, index: true

      t.jsonb :information, default: {}, null: false

      t.timestamps null: false
      t.datetime :fixed_at
    end
    add_index :issues, [:issue_type, :fixed_at]
    add_index :issues, [:assigned_to_id, :fixed_at]
    add_index :issues, :information, using: :gin

    create_table :issue_objects do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.belongs_to :issue, index: true
      t.belongs_to :object, polymorphic: true, index: true
    end

    create_table :issue_unreads do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.belongs_to :admin, index: false
      t.belongs_to :issue, index: true
    end
    add_index :issue_unreads, [:admin_id, :issue_id], unique: true
  end
end
