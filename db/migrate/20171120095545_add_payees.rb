# frozen_string_literal: true

class AddPayees < ActiveRecord::Migration[5.1]
  def change
    create_table :payees do |t|
      t.string :name, null: false
      t.references :scope
      t.string :iban
    end

    create_table :campaigns do |t|
      t.string :campaign_code, null: false
      t.references :payee
      t.string :description
    end

    add_index :campaigns, [:campaign_code], unique: true

    add_reference :orders, :campaign
  end
end
