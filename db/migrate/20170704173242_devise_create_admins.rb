# frozen_string_literal: true

class DeviseCreateAdmins < ActiveRecord::Migration[5.1]
  def change
    create_table :admins do |t|
      t.references :person, null: false
      t.string :roles, array: true, null: false
      t.references :scope

      ## Database authenticatable
      t.string :username, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Trackable
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip

      ## Lockable
      t.integer :failed_attempts, default: 0, null: false
      t.datetime :locked_at

      t.timestamps null: false
      t.datetime :deleted_at
    end

    add_index :admins, :username, unique: true
  end
end
