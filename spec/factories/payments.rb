# frozen_string_literal: true

require "iban_bic/random"

FactoryGirl.define do
  factory :credit_card, class: :"payment_methods/credit_card" do
    transient do
      expires_at { 4.years.from_now }
    end

    person
    payment_processor { :redsys }
    authorization_token { "1234567890abcdef" }
    expiration_year { expires_at.year }
    expiration_month { expires_at.month }

    trait :expired do
      expires_at { 2.month.ago }
    end

    trait :external do
      return_url { "test" }
      authorization_token { nil }
      expiration_year { nil }
      expiration_month { nil }
    end

    trait :external_verified do
      authorization_token { "f9b36152f049a8fbe6a800bcb49837cfb4808d37" }
      expiration_year { "2020" }
      expiration_month { "12" }
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
    payment_method { FactoryGirl.create(:direct_debit, person: person) }

    currency { "EUR" }
    amount { Faker::Number.between(1, 10_000) }

    description { Faker::Lorem.sentence(1, true, 4) }

    trait :credit_card do
      payment_method { FactoryGirl.build(:credit_card, person: person) }
    end

    trait :external do
      payment_method { FactoryGirl.build(:credit_card, :external, person: person) }
    end

    trait :external_verified do
      payment_method { FactoryGirl.build(:credit_card, :external_verified, person: person) }
    end

    trait :external_invalid do
      payment_method { FactoryGirl.build(:credit_card, :external_verified, authorization_token: "invalid", person: person) }
    end

    trait :processed do
      state { :processed }
      processed_at { Faker::Time.between(3.days.ago, 1.day.ago, :all) }
      processed_by { build(:admin) }
    end

    trait :verified do
      payment_method { FactoryGirl.build(:direct_debit, :verified, person: person) }
    end
  end

  factory :orders_batch do
    transient do
      debit_orders { 2 }
      debit_orders_verified { 2 }
      credit_card_orders_verified { 2 }
      credit_card_orders_invalid { 2 }
    end

    description { Faker::Lorem.sentence(1, true, 4) }

    after :build do |orders_batch, evaluator|
      orders_batch.orders = build_list(:order, evaluator.debit_orders, orders_batch: orders_batch)
      orders_batch.orders += build_list(:order, evaluator.debit_orders_verified, :verified, orders_batch: orders_batch)
      orders_batch.orders += build_list(:order, evaluator.credit_card_orders_verified, :credit_card, :external_verified, orders_batch: orders_batch)
      orders_batch.orders += build_list(:order, evaluator.credit_card_orders_invalid, :credit_card, :external_invalid, orders_batch: orders_batch)
    end

    trait :debit_only do
      credit_card_orders_invalid { 0 }
      credit_card_orders_verified { 0 }
    end
  end

  factory :bic do
    country "ES"
    bank_code { Faker::Number.between(1, 10_000).to_s.rjust(4, "0") }
    bic { SecureRandom.base58(8).upcase }
  end
end
