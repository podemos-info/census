# frozen_string_literal: true

class AddEncryptedSensibleDataToPaymentMethods < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_methods, :encrypted_sensible_data, :string
  end
end
