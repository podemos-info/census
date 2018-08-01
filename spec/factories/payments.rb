# frozen_string_literal: true

require "iban_bic/random"

FactoryBot.define do
  sequence(:campaign_code) do |n|
    "#{Faker::Lorem.word}-#{n}"
  end

  factory :credit_card, class: :"payment_methods/credit_card" do
    transient do
      expires_at { 4.years.from_now }
    end

    person
    payment_processor { :redsys }
    authorization_token { "1234567890abcdef" }
    expiration_year { expires_at.year.to_s }
    expiration_month { expires_at.month.to_s }

    trait :expired do
      expires_at { 2.months.ago }
    end

    trait :external do
      return_url { "test" }
      authorization_token { nil }
      expiration_year { nil }
      expiration_month { nil }
    end

    trait :external_verified do
      authorization_token { "f9b36152f049a8fbe6a800bcb49837cfb4808d37" }
      expires_at { 1.year.from_now }
      verified { true }
    end
  end

  factory :direct_debit, class: :"payment_methods/direct_debit" do
    person
    iban { IbanBic.random_iban(tags: [:sepa], not_tags: [:fixed_iban_check]) }
    payment_processor { :sepa }

    trait :verified do
      verified { true }
    end

    trait :non_sepa do
      iban { IbanBic.random_iban(not_tags: [:fixed_iban_check, :sepa]) }
    end
  end

  factory :order do
    person
    payment_method { create(:direct_debit, person: person) }

    currency { "EUR" }
    amount { Faker::Number.between(1, 10_000) }
    description { Faker::Lorem.sentence(1, true, 4) }
    campaign

    trait :credit_card do
      payment_method { build(:credit_card, person: person) }
    end

    trait :external do
      payment_method { build(:credit_card, :external, person: person) }
    end

    trait :external_verified do
      payment_method { build(:credit_card, :external_verified, person: person) }
    end

    trait :external_invalid do
      payment_method { build(:credit_card, :external_verified, authorization_token: "invalid", person: person) }
    end

    trait :verified do
      payment_method { build(:direct_debit, :verified, person: person) }
    end

    trait :processed do
      state { :processed }
      processed_at { Faker::Time.between(3.days.ago, 1.day.ago, :between) }
      processed_by { build(:admin) }
      response_code "0000"
      after :build do |order|
        order.payment_method.response_code = order.response_code
      end
    end

    trait :user_issue do
      response_code "0180"
    end
    trait :finances_issue do
      response_code "0102"
    end
    trait :system_issue do
      response_code "9999"
    end
  end

  factory :orders_batch do
    transient do
      debit_orders { 2 }
      debit_orders_verified { 2 }
      debit_orders_processed { 0 }
      credit_card_orders_verified { 2 }
      credit_card_orders_invalid { 2 }
      credit_card_orders_processed { 0 }
    end

    description { Faker::Lorem.sentence(1, true, 4) }

    after :build do |orders_batch, evaluator|
      orders_batch.orders = build_list(:order, evaluator.debit_orders, orders_batch: orders_batch)
      orders_batch.orders += build_list(:order, evaluator.debit_orders_verified, :verified, orders_batch: orders_batch)
      orders_batch.orders += build_list(:order, evaluator.credit_card_orders_verified, :credit_card, :external_verified, orders_batch: orders_batch)
      orders_batch.orders += build_list(:order, evaluator.credit_card_orders_invalid, :credit_card, :external_invalid, orders_batch: orders_batch)
      orders_batch.orders += build_list(:order, evaluator.debit_orders_processed, :credit_card, :processed, orders_batch: orders_batch,
                                                                                                            processed_by: orders_batch.processed_by,
                                                                                                            processed_at: orders_batch.processed_at)
      orders_batch.orders += build_list(:order, evaluator.credit_card_orders_processed, :credit_card, :processed, orders_batch: orders_batch,
                                                                                                                  processed_by: orders_batch.processed_by,
                                                                                                                  processed_at: orders_batch.processed_at)
    end

    trait :debit_only do
      credit_card_orders_invalid { 0 }
      credit_card_orders_verified { 0 }
    end

    trait :processed do
      credit_card_orders_processed { 2 }
      debit_orders_processed { 2 }
      processed_at { Faker::Time.between(3.days.ago, 1.day.ago, :between) }
      processed_by { build(:admin) }
    end

    trait :with_issues do
      after :create do |orders_batch|
        create(:missing_bic, issuable: orders_batch.orders.first.payment_method)
      end
    end
  end

  factory :bic do
    country "ES"
    bank_code { Faker::Number.between(1, 10_000).to_s.rjust(4, "0") }
    bic { "#{[*("A".."Z")].sample(4).join}#{country}#{[*("A".."Z")].sample(2).join}" }

    trait :invalid do
      bic { "1eE23" }
    end
  end

  factory :campaign do
    description { Faker::Lorem.sentence(1, true, 4) }
    campaign_code { generate(:campaign_code) }
  end

  factory :payee do
    name { Faker::Lorem.sentence(1, true, 4) }
    iban { IbanBic.random_iban(tags: [:sepa], not_tags: [:fixed_iban_check]) }
    scope
  end
end
