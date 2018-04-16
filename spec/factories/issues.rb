# frozen_string_literal: true

FactoryBot.define do
  sequence(:job_id) do |n|
    "ACTIVE-JOB-#{n}"
  end

  factory :issue do
    transient do
      issuable nil
      evaluated true
    end
    level { "medium" }

    after :build do |issue, evaluator|
      issue.issuable = evaluator.issuable
    end

    trait :not_evaluated do
      evaluated false
    end

    trait :fixed do
      close_result { :fixed }
      closed_at { Time.zone.now }
    end

    trait :gone do
      close_result { :gone }
      closed_at { Time.zone.now }
    end
  end

  factory :admin_remark, parent: :issue, class: :"issues/people/admin_remark" do
    transient do
      issuable { create(:document_verification) }
    end
    role { "lopd" }
    explanation { Faker::Lorem.paragraph(1, true, 2) }

    after :build do |issue, evaluator|
      if evaluator.evaluated
        issue.people = [evaluator.issuable.person]
        issue.procedures << evaluator.issuable
      end
    end
  end

  factory :duplicated_document, parent: :issue, class: :"issues/people/duplicated_document" do
    transient do
      issuable { create(:registration, person_copy_data: other_person) }
      other_person { create(:person) }
    end
    role { "lopd" }
    document_type { other_person.document_type }
    document_id { other_person.document_id }
    document_scope_id { other_person.document_scope_id }

    trait :ready_to_fix do
      cause :mistake
      chosen_person_id { issuable.person.id }
    end

    after :build do |issue, evaluator|
      if evaluator.evaluated
        issue.people = [evaluator.other_person, evaluator.issuable.person]
        issue.procedures << evaluator.issuable
      end
    end
  end

  factory :duplicated_person, parent: :issue, class: :"issues/people/duplicated_person" do
    transient do
      issuable { create(:registration, person_copy_data: other_person) }
      other_person { create(:person) }
    end
    role { "lopd" }
    first_name { other_person.first_name }
    last_name1 { other_person.last_name1 }
    last_name2 { other_person.last_name2 }
    born_at { other_person.born_at }

    trait :ready_to_fix do
      cause :mistake
      chosen_person_ids { [issuable.person.id] }
    end

    after :build do |issue, evaluator|
      if evaluator.evaluated
        issue.people = [evaluator.other_person, evaluator.issuable.person]
        issue.procedures << evaluator.issuable
      end
    end
  end

  factory :untrusted_email, parent: :issue, class: :"issues/people/untrusted_email" do
    transient do
      issuable { create(:registration, person_copy_data: temp_person) }
      temp_person { build(:person, email: "#{Faker::Internet.user_name}@#{Issues::People::UntrustedEmail.domains_blacklist.first}") }
    end
    role { "lopd" }
    email { temp_person.email }

    after :build do |issue, evaluator|
      if evaluator.evaluated
        issue.people = [evaluator.issuable.person]
        issue.procedures << evaluator.issuable
      end
    end

    trait :enabled_person do
      issuable { create(:person_data_change, changing_columns: [:email], person_copy_data: temp_person) }
    end
  end

  factory :untrusted_phone, parent: :issue, class: :"issues/people/untrusted_phone" do
    transient do
      issuable { create(:registration, person_copy_data: temp_person) }
      temp_person { build(:person, phone: Issues::People::UntrustedPhone.phones_blacklist.first) }
    end
    role { "lopd" }
    phone { temp_person.phone }

    after :build do |issue, evaluator|
      if evaluator.evaluated
        issue.people = [evaluator.issuable.person]
        issue.procedures << evaluator.issuable
      end
    end

    trait :enabled_person do
      issuable { create(:person_data_change, changing_columns: [:phone], person_copy_data: temp_person) }
    end
  end

  factory :missing_bic, parent: :issue, class: :"issues/payments/missing_bic" do
    transient do
      issuable { create(:direct_debit) }
    end
    role { "finances" }

    after :build do |issue, evaluator|
      iban = evaluator.issuable.iban
      parts = IbanBic.parse(iban)
      issue.information = {
        country: parts[:country],
        bank_code: parts[:bank],
        iban: iban
      }
    end
    after :create do |issue, evaluator|
      if evaluator.evaluated
        issue.orders << evaluator.issuable.orders
        issue.payment_methods << evaluator.issuable
      end
    end
  end

  factory :processing_issue, parent: :issue, class: :"issues/payments/processing_issue" do
    transient do
      issuable { create(:order, :processed) }
    end
    role { "finances" }
    response_code { issuable.response_code }

    after :build do |issue, evaluator|
      if evaluator.evaluated
        issue.orders << evaluator.issuable
        issue.payment_methods << evaluator.issuable.payment_method
      end
    end

    trait :system do
      role { "system" }
    end
  end

  factory :issue_unread do
    issue { create(:duplicated_document) }
    admin { create(:admin, role: "lopd") }
  end
end
