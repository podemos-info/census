# frozen_string_literal: true

class MigrateToDiscard < ActiveRecord::Migration[5.1]
  def change
    rename_column :admins, :deleted_at, :discarded_at
    rename_column :orders, :deleted_at, :discarded_at
    rename_column :payment_methods, :deleted_at, :discarded_at
    rename_column :people, :deleted_at, :discarded_at
  end
end
