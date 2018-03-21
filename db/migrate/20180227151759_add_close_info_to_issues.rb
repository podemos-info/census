# frozen_string_literal: true

class AddCloseInfoToIssues < ActiveRecord::Migration[5.1]
  def change
    rename_column :issues, :fixed_at, :closed_at
    add_column :issues, :fix_information, :jsonb, default: {}, null: false
    add_column :issues, :close_result, :integer
  end
end
