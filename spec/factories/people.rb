# frozen_string_literal: true

require "faker/spanish_document"
require "census/faker/localized"

FactoryBot.define do
  sequence(:decidim_id)

  sequence(:scope_name) do |n|
    "#{Faker::Lorem.sentence(1, true, 3)} #{n}"
  end

  sequence(:scope_code) do |n|
    "#{Faker::Lorem.characters(4).upcase}-#{n}"
  end

  factory :scope_type do
    name { Census::Faker::Localized.word }
    plural { Census::Faker::Localized.literal(name.values.first.pluralize) }
  end

  factory :scope do
    name { Census::Faker::Localized.literal(generate(:scope_name)) }
    code { generate(:scope_code) }
    association :scope_type, factory: :scope_type, strategy: :build

    trait :local do
      name { Census::Faker::Localized.literal("local") }
      code { Settings.regional.local_code }
      initialize_with { Scope.find_or_create_by(code: Settings.regional.local_code) }
    end

    trait :non_local do
      name { Census::Faker::Localized.literal("non_local") }
      code { Settings.regional.non_local_code }
      initialize_with { Scope.find_or_create_by(code: Settings.regional.non_local_code) }
    end

    factory :local_scope, traits: [:local]
    factory :non_local_scope, traits: [:non_local]
  end

  factory :person do
    transient do
      foreign { Faker::Boolean.boolean(0.1) }
      non_local { Faker::Boolean.boolean(0.1) }
    end

    first_name { Faker::Name.first_name }
    last_name1 { Faker::Name.last_name }
    last_name2 { Faker::Name.last_name }
    born_at { Faker::Date.between(99.years.ago, 18.years.ago) }
    gender { Person.genders.keys.sample }
    address { Faker::Address.street_address }
    postal_code { Faker::Address.zip_code }
    email { Faker::Internet.unique.email }
    phone { "003467" + Faker::Number.number(7) }
    created_at { Faker::Time.between(3.years.ago, 3.days.ago, :between) }
    scope { nil }
    document_scope { nil }
    address_scope { nil }
    state { :enabled }
    external_ids { { "participa2-1" => generate(:decidim_id) } }
    membership_level { :follower }

    after :build do |person, evaluator|
      foreign = evaluator.foreign

      if person.document_type
        foreign = true if person.document_type.to_sym == :nie
        foreign = false if person.document_type.to_sym == :dni
      else
        person.document_type = [foreign ? :dni : :nie, :passport].sample
      end
      person.document_id = Faker::SpanishDocument.generate(person.document_type) if person.document_id.blank?

      local_scope = create(:local_scope)
      non_local_scope = create(:non_local_scope)

      person.scope ||= create(:scope, parent: local_scope)
      person.address_scope ||= evaluator.non_local ? create(:scope) : person.scope
      person.document_scope ||= foreign && person.document_type == :passport ? create(:scope) : local_scope
    end

    trait :pending do
      born_at { nil }
      gender { nil }
      address { nil }
      postal_code { nil }
      email { nil }
      phone { nil }
      created_at { nil }
      state { :pending }

      after :build do |person|
        person.document_id = nil
        person.document_type = nil
        person.scope_id = nil
        person.address_scope_id = nil
        person.document_scope_id = nil
      end
    end

    trait :young do
      born_at { Faker::Date.between(18.years.ago, 14.years.ago) }
    end

    trait :verified do
      verification { :verified }
    end

    trait :member do
      verification { :verified }
      membership_level { :member }
    end

    trait :phone_verified do
      phone_verification { :verified }
    end

    trait :copy do
      transient do
        from { build(:person) }
      end

      after :build do |person, evaluator|
        person.assign_attributes evaluator.from.attributes
        person.id = nil
      end
    end

    trait :cancelled do
      state { :cancelled }
      discarded_at { Faker::Date.between(created_at, Time.current) }
    end

    trait :trashed do
      state { :trashed }
      discarded_at { Faker::Date.between(created_at, Time.current) }
    end
  end

  factory :download do
    association :person, factory: :person, strategy: :build
    expires_at { Faker::Date.between(1.day.from_now, 30.days.from_now) }
    file { test_file("attachment-non-image.pdf", "application/pdf") }

    trait :discarded do
      created_at { Faker::Date.between(1.day.from_now, 30.days.from_now) }
      discarded_at { Faker::Date.between(created_at, Time.current) }
    end
  end

  factory :person_location do
    person { create(:person) }
    ip { Faker::Internet.ip_v4_address }
    user_agent { Faker::Internet.user_agent }
    created_at { Faker::Date.between(1.day.from_now, 30.days.from_now) }
    updated_at { Faker::Date.between(Time.current, created_at) }
  end
end
