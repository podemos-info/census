# frozen_string_literal: true

class CreatePersonLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :person_locations do |t|
      t.references :person, null: false
      t.string :ip
      t.text :user_agent

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
