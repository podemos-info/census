# frozen_string_literal: true

FactoryBot.define do
  sequence(:username) do |n|
    "#{Faker::Internet.user_name}#{n}"
  end

  factory :admin do
    person { create(:person) }
    username { generate(:username) }
    password { Faker::Internet.password }
    role { "system" }

    trait :data do
      role { "data" }
    end

    trait :finances do
      role { "finances" }
    end

    trait :data_help do
      role { "data_help" }
    end
  end

  factory :event do
    transient do
      visit { create(:visit) }
    end
    visit_id { visit.id }
    admin { visit.admin }
    name { "page_view" }
    properties { { controller: "dashboard", action: "index" } }
    time { Time.zone.now }

    trait :person_view do
      transient do
        person { create(:person) }
      end
      properties { { controller: "people", action: "show", id: person.id } }
    end

    trait :people_search do
      transient do
        q { { "first_name_contains" => "test" } }
      end
      properties { { controller: "people", action: "index", q: q } }
    end

    trait :security_report do
      name { "security_report" }
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
    utm_source { "" }
    utm_medium { "" }
    utm_term { "" }
    utm_content { "" }
    utm_campaign { "" }
    started_at { Time.zone.now }
  end

  factory :version do
    transient do
      object { create(:person) }
      changes { { first_name: "Changed first_name" } }
      admin { create(:admin) }
    end

    to_create { |instance| instance } # initialized version is already saved

    initialize_with do
      PaperTrail.request.whodunnit = admin
      object.update! changes
      object.versions.last
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
        PaperTrail.request.whodunnit = admin
        object.versions.last
      end
    end

    trait :deletion do
      initialize_with do
        PaperTrail.request.whodunnit = admin
        object.discard
        object.versions.last
      end
    end

    trait :order do
      transient do
        object { create(:order) }
        changes { { description: "What a description!" } }
      end
    end

    trait :procedure do
      transient do
        object { create(:document_verification) }
        changes { { comment: "What a procedure!" } }
      end
    end
  end
end
