# frozen_string_literal: true

class AddPhoneVerificationToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :phone_verification, :integer
  end
end
