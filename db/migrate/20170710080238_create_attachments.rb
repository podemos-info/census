# frozen_string_literal: true

class CreateAttachments < ActiveRecord::Migration[5.1]
  def change
    create_table :attachments do |t|
      t.references :procedure, foreign_key: true
      t.string :file, null: false
      t.string :content_type

      t.timestamps
    end
  end
end
