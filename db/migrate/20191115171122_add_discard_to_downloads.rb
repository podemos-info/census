# frozen_string_literal: true

class AddDiscardToDownloads < ActiveRecord::Migration[5.2]
  def change
    add_column :downloads, :discarded_at, :timestamp
  end
end
