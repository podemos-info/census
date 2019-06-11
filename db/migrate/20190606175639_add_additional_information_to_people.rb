# frozen_string_literal: true

class AddAdditionalInformationToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :additional_information, :jsonb, null: false, default: {}
  end
end
