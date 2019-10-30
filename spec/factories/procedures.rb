# frozen_string_literal: true

FactoryBot.define do
  factory :attachment do
    file { test_file("attachment-image.png", "image/png") }
    association :procedure, factory: :document_verification, strategy: :build

    trait :non_image do
      file { test_file("attachment-non-image.pdf", "application/pdf") }
    end
  end

  factory :procedure, class: :procedure do
    association :person, factory: :person, strategy: :build
    information { {} }
    created_at { Faker::Time.between(person.created_at, Time.current, :between) }
    prioritized_at { nil }

    after :build do |procedure, _evaluator|
      procedure.type ||= "Procedures::DocumentVerification"
    end

    trait :cancelled_person do
      person { build(:person, :cancelled) }
    end

    trait :ready_to_process do
      processed_by { build(:admin) }
      processed_at { Time.current + 1.second }
      comment { Faker::Lorem.paragraph(1, true, 2) }
    end

    trait :processed do
      processed_by { build(:admin) }
      processed_at { Faker::Time.between(created_at, [Settings.procedures.undo_minutes.minutes.ago, created_at].max, :between) }
      state { Faker::Boolean.boolean(0.7) ? :accepted : :rejected }
      comment { Faker::Lorem.paragraph(1, true, 2) }
    end

    trait :autoprocessed do
      processed_by { nil }
      processed_at { Faker::Time.between(created_at, [Settings.procedures.undo_minutes.minutes.ago, created_at].max, :between) }
      state { :accepted }
      comment { "" }
    end

    trait :undoable do
      after :create do |procedure|
        procedure.processed_by = build(:admin)
        procedure.processed_at = Time.current
        procedure.comment = Faker::Lorem.paragraph(1, true, 2)
        procedure.accept!
      end
    end

    trait :undoable_rejected do
      after :create do |procedure|
        procedure.processed_by = build(:admin)
        procedure.processed_at = Time.current
        procedure.comment = Faker::Lorem.paragraph(1, true, 2)
        procedure.reject!
      end
    end

    trait :with_attachments do
      after :build do |procedure|
        procedure.attachments.build(attributes_for_list(:attachment, 1, procedure: procedure))
        procedure.attachments.build(attributes_for_list(:attachment, 1, :non_image, procedure: procedure))
      end
    end

    trait :prioritized do
      prioritized_at { Time.current }
    end
  end

  factory :document_verification, parent: :procedure, class: :"procedures/document_verification" do
    person { create(:person) }
  end

  factory :membership_level_change, parent: :procedure, class: :"procedures/membership_level_change" do
    from_membership_level { person.membership_level }
    to_membership_level { "member" }

    person { create(:person, :verified) }

    trait :not_acceptable do
      person { create(:person) }
    end
  end

  factory :registration, parent: :procedure, class: :"procedures/registration" do
    transient do
      person_copy_data { build(:person) }
    end

    person { create(:person, :pending) }
    person_data do
      {
        first_name: person.first_name,
        last_name1: person.last_name1,
        last_name2: person.last_name2,
        document_type: person_copy_data.document_type,
        document_id: person_copy_data.document_id,
        born_at: person_copy_data.born_at,
        gender: person_copy_data.gender,
        address: person_copy_data.address,
        postal_code: person_copy_data.postal_code,
        email: person_copy_data.email,
        phone: person_copy_data.phone,
        scope_id: person_copy_data.scope.id,
        address_scope_id: person_copy_data.address_scope.id,
        document_scope_id: person_copy_data.document_scope.id,
        external_ids: person_copy_data.external_ids
      }
    end
    created_at { Faker::Time.between(3.years.ago, 3.days.ago, :all) }
  end

  factory :person_data_change, parent: :procedure, class: :"procedures/person_data_change" do
    transient do
      person_copy_data { build(:person) }
      changing_columns { [:first_name] }
    end

    person
    person_data do
      ret = {}
      ret[:first_name] = person_copy_data.first_name if changing_columns.include? :first_name
      ret[:last_name1] = person_copy_data.last_name1 if changing_columns.include? :last_name1
      ret[:last_name2] = person_copy_data.last_name2 if changing_columns.include? :last_name2
      ret[:document_type] = person_copy_data.document_type if changing_columns.include? :document_type
      ret[:document_id] = person_copy_data.document_id if changing_columns.include? :document_id
      ret[:born_at] = person_copy_data.born_at if changing_columns.include? :born_at
      ret[:gender] = person_copy_data.gender if changing_columns.include? :gender
      ret[:address] = person_copy_data.address if changing_columns.include? :address
      ret[:postal_code] = person_copy_data.postal_code if changing_columns.include? :postal_code
      ret[:email] = person_copy_data.email if changing_columns.include? :email
      ret[:phone] = person_copy_data.phone if changing_columns.include? :phone
      ret[:scope_id] = person_copy_data.scope.id if changing_columns.include? :scope_id
      ret[:address_scope_id] = person_copy_data.address_scope.id if changing_columns.include? :address_scope_id
      ret[:document_scope_id] = person_copy_data.document_scope.id if changing_columns.include? :document_scope_id
      ret
    end

    created_at { Faker::Time.between(3.years.ago, 3.days.ago, :all) }
  end

  factory :cancellation, parent: :procedure, class: :"procedures/cancellation" do
    channel { %w(decidim email phone).sample }
    reason { Faker::Lorem.paragraph(1, true, 2) }
    person
  end

  factory :phone_verification, parent: :procedure, class: :"procedures/phone_verification" do
    phone { nil }
    person

    trait :phone_modification do
      phone { "0034" + Faker::Number.number(9) }
    end
  end
end
