# frozen_string_literal: true

require "census/faker/localized"
require "census/faker/document_id"

FactoryGirl.define do
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
    scope_type
  end

  factory :person do
    first_name { Faker::Name.first_name }
    last_name1 { Faker::Name.last_name }
    last_name2 { Faker::Name.last_name }
    document_type { Person::DOCUMENT_TYPES.sample }
    document_id { Census::Faker::DocumentId.generate(document_type) }
    document_scope { scope }
    born_at { Faker::Date.between(99.year.ago, 18.year.ago) }
    gender { Person::GENDERS.sample }
    address { Faker::Address.street_address }
    address_scope { scope }
    postal_code { Faker::Address.zip_code }
    email { Faker::Internet.unique.email }
    phone { "0034" + Faker::Number.number(9) }
    scope
    created_at { Faker::Time.between(3.years.ago, 3.day.ago, :all) }

    trait :young do
      born_at { Faker::Date.between(18.year.ago, 14.year.ago) }
    end

    trait :verified do
      verified_by_document { true }
    end
  end

  factory :attachment do
    file { test_file("attachment-image.png", "image/png") }
    procedure { build(:verification_document) }
  end

  factory :procedure, class: Procedure do
    person
    information { {} }
    created_at { Faker::Time.between(person.created_at, 3.day.ago, :all) }

    trait :processed do
      processed_by { person }
      processed_at { Faker::Time.between(created_at, DateTime.now, :all) }
      state { Faker::Boolean.boolean(0.7) ? :accepted : :rejected }
      comment { Faker::Lorem.paragraph(1, true, 2) }
    end

    trait :with_attachments do
      ignore do
        number_of_attachments 2
      end
    
      after :build do |procedure, evaluator|
        procedure.attachments.build(attributes_for_list(:attachment, evaluator.number_of_attachments, procedure: procedure))
      end
    end
  end

  factory :verification_document, parent: :procedure, class: VerificationDocument do
  end
end

def test_file(filename, content_type)
  Rack::Test::UploadedFile.new(File.expand_path(File.join(__dir__, "fixtures", "files", filename)), content_type)
end
