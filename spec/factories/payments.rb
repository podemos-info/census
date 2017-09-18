# frozen_string_literal: true

require "census/faker/bank"

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

    trait :external_authorized do
      authorization_token { "f9b36152f049a8fbe6a800bcb49837cfb4808d37" }
      expiration_year { 2020 }
      expiration_month { 12 }
    end
  end

  factory :direct_debit, class: :"payment_methods/direct_debit" do
    person
    iban { Census::Faker::Bank.iban("ES") }
    bic { Faker::Bank.swift_bic }
    payment_processor { :sepa }

    trait :verified do
      verified { true }
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

    trait :external_authorized do
      payment_method { FactoryGirl.build(:credit_card, :external_authorized, person: person) }
    end

    trait :external_invalid do
      payment_method { FactoryGirl.build(:credit_card, :external_authorized, authorization_token: "invalid", person: person) }
    end

    trait :processed do
      state { :processed }
    end

    trait :verified do
      payment_method { FactoryGirl.build(:direct_debit, :verified, person: person) }
    end
  end

  factory :orders_batch do
    description { Faker::Lorem.sentence(1, true, 4) }

    after :build do |orders_batch|
      orders_batch.orders = build_list(:order, 2, orders_batch: orders_batch)
      orders_batch.orders = build_list(:order, 2, :verified, orders_batch: orders_batch)
      orders_batch.orders += build_list(:order, 2, :credit_card, :external_authorized, orders_batch: orders_batch)
      orders_batch.orders += build_list(:order, 2, :credit_card, :external_invalid, orders_batch: orders_batch)
    end
  end
end
