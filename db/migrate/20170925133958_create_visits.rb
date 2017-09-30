# frozen_string_literal: true

class CreateVisits < ActiveRecord::Migration[5.1]
  def change
    create_table :visits do |t|
      t.string :visit_token
      t.string :visitor_token

      # standard
      t.string :ip
      t.text :user_agent
      t.text :referrer
      t.text :landing_page

      # user
      t.references :admin

      # traffic source
      t.string :referring_domain
      t.string :search_keyword

      # technology
      t.string :browser
      t.string :os
      t.string :device_type
      t.integer :screen_height
      t.integer :screen_width

      # location
      t.string :country
      t.string :region
      t.string :city
      t.string :postal_code
      t.decimal :latitude
      t.decimal :longitude

      # utm parameters
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_term
      t.string :utm_content
      t.string :utm_campaign

      t.timestamp :started_at
    end

    add_index :visits, [:visit_token], unique: true
  end
end
