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
      code { Settings.local_code }
      initialize_with { Scope.find_or_create_by(code: Settings.local_code) }
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

  factory :attachment do
    file { test_file("attachment-image.png", "image/png") }
    association :procedure, factory: :verification_document, strategy: :build

    trait :non_image do
      file { test_file("attachment-non-image.pdf", "application/pdf") }
    end
  end

  factory :procedure, class: Procedure do
    association :person, factory: :person, strategy: :build
    information { {} }
    created_at { Faker::Time.between(person.created_at, 3.day.ago, :all) }

    trait :ready_to_process do
      processed_by { build(:person) }
      processed_at { Time.now }
      comment { Faker::Lorem.paragraph(1, true, 2) }
    end

    trait :processed do
      processed_by { build(:person) }
      processed_at { Faker::Time.between(created_at, Settings.undo_minutes.minutes.ago, :all) }
      state { Faker::Boolean.boolean(0.7) ? :accepted : :rejected }
      comment { Faker::Lorem.paragraph(1, true, 2) }
    end

    trait :undoable do
      after :create do |procedure|
        procedure.processed_by = build(:person)
        procedure.processed_at = Time.now
        procedure.comment = Faker::Lorem.paragraph(1, true, 2)
        procedure.accept!

        procedure.dependent_procedures.each do |dependent_procedure|
          dependent_procedure.processed_by = procedure.processed_by
          dependent_procedure.processed_at = procedure.processed_at
          dependent_procedure.comment = procedure.comment
          dependent_procedure.accept!
        end
      end
    end

    trait :undoable_rejected do
      after :create do |procedure|
        procedure.processed_by = build(:person)
        procedure.processed_at = Time.now
        procedure.comment = Faker::Lorem.paragraph(1, true, 2)
        procedure.reject!

        procedure.dependent_procedures.each do |dependent_procedure|
          dependent_procedure.processed_by = procedure.processed_by
          dependent_procedure.processed_at = procedure.processed_at
          dependent_procedure.comment = procedure.comment
          dependent_procedure.reject!
        end
      end
    end

    trait :with_attachments do
      after :build do |procedure|
        procedure.attachments.build(attributes_for_list(:attachment, 1, procedure: procedure))
        procedure.attachments.build(attributes_for_list(:attachment, 1, :non_image, procedure: procedure))
      end
    end
  end

  factory :verification_document, parent: :procedure, class: Procedures::VerificationDocument do
    trait :with_dependent_procedure do
      after :create do |procedure|
        create(:membership_level_change, depends_on: procedure, person: procedure.person)
      end
    end
  end

  factory :membership_level_change, parent: :procedure, class: Procedures::MembershipLevelChange do
    from_level { person.level }
    to_level "member"
  end
end

def test_file(filename, content_type)
  Rack::Test::UploadedFile.new(File.expand_path(File.join(__dir__, "fixtures", "files", filename)), content_type)
end
