# frozen_string_literal: true

class AddDownloadObjects < ActiveRecord::Migration[5.2]
  def change
    create_table :download_objects do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.belongs_to :download, index: true
      t.belongs_to :object, polymorphic: true, index: true
    end
  end
end
