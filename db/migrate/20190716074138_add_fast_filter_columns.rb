# frozen_string_literal: true

class AddFastFilterColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :fast_filter, :tsvector
    add_index :people, :fast_filter, using: "gin"

    add_column :procedures, :fast_filter, :tsvector
    add_index :procedures, :fast_filter, using: "gin"
  end
end
