# frozen_string_literal: true

require "census/faker/localized"
require "census/faker/document_id"

FactoryGirl.define do
  sequence(:participa_id)

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

  factory :scope, aliases: [:address_scope, :document_scope] do
    name { Census::Faker::Localized.literal(generate(:scope_name)) }
    code { generate(:scope_code) }
    scope_type

    trait :local do
      name { Census::Faker::Localized.literal("local") }
      code { Settings.regional.local_code }
      initialize_with { Scope.find_or_create_by(code: Settings.regional.local_code) }
    end

    factory :local_scope, traits: [:local]
  end

  factory :person do
    transient do
      foreign { Faker::Boolean.boolean(0.1) }
      non_local { Faker::Boolean.boolean(0.1) }
    end

    first_name { Faker::Name.first_name }
    last_name1 { Faker::Name.last_name }
    last_name2 { Faker::Name.last_name }
    born_at { Faker::Date.between(99.year.ago, 18.year.ago) }
    gender { Person.genders.keys.sample }
    address { Faker::Address.street_address }
    postal_code { Faker::Address.zip_code }
    email { Faker::Internet.unique.email }
    phone { "0034" + Faker::Number.number(9) }
    created_at { Faker::Time.between(3.years.ago, 3.day.ago, :all) }
    extra { { participa_id: generate(:participa_id) } }

    address_scope
    document_scope

    after :build do |person, evaluator|
      foreign = evaluator.foreign
      if person.document_type
        foreign = person.document_type.to_sym != :dni
      else
        person.document_type = evaluator.foreign ? :dni : [:nie, :passport].sample
        person.document_id = nil
      end
      person.document_id = Census::Faker::DocumentId.generate(person.document_type) unless person.document_id.present?

      local_scope = create(:local_scope)
      person.scope = create(:scope, parent: local_scope)
      person.address_scope = person.scope unless evaluator.non_local
      person.document_scope = local_scope unless foreign
    end

    trait :young do
      born_at { Faker::Date.between(18.year.ago, 14.year.ago) }
    end

    trait :verified do
      verified_by_document { true }
    end
  end

  factory :download do
    association :person, factory: :person, strategy: :build
    expires_at { Faker::Date.between(1.day.from_now, 30.days.from_now) }
    file { test_file("attachment-non-image.pdf", "application/pdf") }
  end
end
