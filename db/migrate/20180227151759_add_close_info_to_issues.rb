# frozen_string_literal: true

class AddCloseInfoToIssues < ActiveRecord::Migration[5.1]
  def change
    change_table :issues, bulk: true do |t|
      t.rename :fixed_at, :closed_at
      t.jsonb :fix_information, default: {}, null: false
      t.integer :close_result
    end
  end
end
