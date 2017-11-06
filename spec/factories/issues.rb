# frozen_string_literal: true

FactoryBot.define do
  factory :issue do
    issue_type { :duplicated_document }
    role { "lopd" }
    level { "medium" }

    trait :payment_issue do
      transient do
        order { nil }
      end
      role { "finances" }
      after :create do |issue, evaluator|
        issue.orders << evaluator.order
        issue.payment_methods << evaluator.order.payment_method
      end
    end

    trait :missing_bic do
      payment_issue
      issue_type { :missing_bic }
      after :build do |issue, evaluator|
        iban = evaluator.order.payment_method.iban
        parts = IbanBic.parse(iban)
        issue.information = {
          country: parts[:country],
          bank_code: parts[:bank],
          iban: iban
        }
      end
    end

    trait :processed_response_code do
      payment_issue
      issue_type { :processed_response_code }
      after :build do |issue, evaluator|
        issue.information = {
          response_code: evaluator.order.response_code
        }
      end
    end

    trait :unknown_error do
      payment_issue
      role { "system" }
      issue_type { :unknown }
    end

    trait :with_people do
      after :build do |issue|
        issue.people = create_list(:person, 2)
      end
    end
  end

  factory :issue_unread do
    issue { create(:issue, :with_people) }
    admin { create(:admin, role: "lopd") }
  end
end
