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
  end

  factory :duplicated_document, parent: :issue, class: :"issues/people/duplicated_document" do
    transient do
      issuable { create(:registration) }
    end
    role { "lopd" }
    document_type { issuable.person.document_type }
    document_id { issuable.person.document_id }
    document_scope_id { issuable.person.document_scope_id }

    after :build do |issue, evaluator|
      if evaluator.evaluated
        issue.people << evaluator.issuable.person
        issue.procedures << evaluator.issuable
      end
    end
  end

  factory :duplicated_person, parent: :issue, class: :"issues/people/duplicated_person" do
    transient do
      issuable { create(:registration) }
    end
    role { "lopd" }
    first_name { issuable.person.first_name }
    last_name1 { issuable.person.last_name1 }
    last_name2 { issuable.person.last_name2 }
    born_at { issuable.person.born_at }

    after :build do |issue, evaluator|
      if evaluator.evaluated
        issue.people << evaluator.issuable.person
        issue.procedures << evaluator.issuable
      end
    end
  end

  factory :missing_bic, parent: :issue, class: :"issues/payments/missing_bic" do
    transient do
      issuable { create(:order) }
    end
    role { "finances" }

    after :build do |issue, evaluator|
      iban = evaluator.issuable.payment_method.iban
      parts = IbanBic.parse(iban)
      issue.information = {
        country: parts[:country],
        bank_code: parts[:bank],
        iban: iban
      }
    end
    after :create do |issue, evaluator|
      if evaluator.evaluated
        issue.orders << evaluator.issuable
        issue.payment_methods << evaluator.issuable.payment_method
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
