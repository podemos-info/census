# frozen_string_literal: true

FactoryGirl.define do
  factory :admin do
    person
    username { Faker::Internet.user_name }
    password { Faker::Internet.password }
    roles { ["admin"] }
  end

  factory :event do
    transient do
      visit { build(:visit) }
    end
    visit_id { visit.id }
    admin { visit.admin }
    name "page_view"
    properties controller: "dashboard", action: "index"
    time { Time.now }

    trait :person_view do
      transient do
        person { create(:person) }
      end
      properties { { controller: "person", action: "show", id: person.id } }
    end
  end

  factory :visit do
    admin
    visit_token { SecureRandom.uuid }
    visitor_token { SecureRandom.uuid }
    ip { Faker::Internet.ip_v4_address }
    user_agent { Faker::Internet.user_agent }
    referrer { Faker::Internet.url }
    landing_page { Faker::Internet.url }
    referring_domain { Faker::Internet.domain_name }
    search_keyword { Faker::Name.name }
    browser { Faker::App.name }
    os { Faker::App.name }
    device_type { Faker::Lorem.word }
    screen_width { Faker::Number.between(320, 3200) }
    screen_height { Faker::Number.between(180, 2000) }
    country { Faker::Address.country }
    region { Faker::Address.state }
    city { Faker::Address.city }
    postal_code { Faker::Address.postcode }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    utm_source ""
    utm_medium ""
    utm_term ""
    utm_content ""
    utm_campaign ""
    started_at { Time.now }
  end

  factory :version do
    transient do
      changes { { first_name: "Changed first_name" } }
    end

    to_create { |instance| instance } # initialized version is already saved

    initialize_with do
      PaperTrail.whodunnit = create(:admin)
      person = create(:person)
      person.update_attributes! changes
      person.versions.last
    end

    trait :many_changes do
      transient do
        changes do
          { first_name: "Changed first_name", last_name1: "Changed last_name1", last_name2: "Changed last_name2",
            address: "Changed address", phone: "Changed phone" }
        end
      end
    end

    trait :creation do
      initialize_with do
        PaperTrail.whodunnit = create(:admin)
        person = create(:person)
        person.versions.last
      end
    end

    trait :deletion do
      initialize_with do
        PaperTrail.whodunnit = create(:admin)
        person = create(:person)
        person.destroy
        person.versions.last
      end
    end
  end
end
