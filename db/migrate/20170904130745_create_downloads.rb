# frozen_string_literal: true

class CreateDownloads < ActiveRecord::Migration[5.1]
  def change
    create_table :downloads do |t|
      t.references :person, null: false
      t.string :file, null: false
      t.string :content_type
      t.datetime :expires_at, null: false
      t.timestamps
    end
  end
end
