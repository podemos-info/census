# frozen_string_literal: true

# This migration creates the `jobs` table.
class CreateJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :jobs do |t|
      t.string :job_id, null: false
      t.string :job_type, null: false
      t.integer :status, null: false, index: true
      t.text :result
      t.integer :user_id, index: true
      t.timestamps
    end

    add_index :jobs, [:job_id], unique: true

    create_table :job_objects do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.belongs_to :job, foreign_key: { to_table: :jobs }, index: true
      t.belongs_to :object, polymorphic: true, index: true
    end

    create_table :job_messages do |t|
      t.belongs_to :job, foreign_key: { to_table: :jobs }, index: true
      t.string :message_type, null: false
      t.datetime :created_at, null: false
      t.text :message, null: false
    end
  end
end
