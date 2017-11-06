# frozen_string_literal: true

FactoryBot.define do
  factory :attachment do
    file { test_file("attachment-image.png", "image/png") }
    association :procedure, factory: :verification_document, strategy: :build

    trait :non_image do
      file { test_file("attachment-non-image.pdf", "application/pdf") }
    end
  end

  factory :procedure, class: :procedure do
    association :person, factory: :person, strategy: :build
    information { {} }
    created_at { Faker::Time.between(person.created_at, 3.day.ago, :all) }

    trait :ready_to_process do
      processed_by { build(:admin) }
      processed_at { Time.now }
      comment { Faker::Lorem.paragraph(1, true, 2) }
    end

    trait :processed do
      processed_by { build(:admin) }
      processed_at { Faker::Time.between(created_at, Settings.misc.undo_minutes.minutes.ago, :all) }
      state { Faker::Boolean.boolean(0.7) ? :accepted : :rejected }
      comment { Faker::Lorem.paragraph(1, true, 2) }
    end

    trait :undoable do
      after :create do |procedure|
        procedure.processed_by = build(:admin)
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
        procedure.processed_by = build(:admin)
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

  factory :verification_document, parent: :procedure, class: :"procedures/verification_document" do
    trait :with_dependent_procedure do
      after :create do |procedure|
        create(:membership_level_change, depends_on: procedure, person: procedure.person)
      end
    end
  end

  factory :membership_level_change, parent: :procedure, class: :"procedures/membership_level_change" do
    from_level { person.level }
    to_level "member"
  end
end
