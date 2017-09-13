# frozen_string_literal: true

require "census/faker/bank"

FactoryGirl.define do
  factory :credit_card, class: :"payment_methods/credit_card" do
    transient do
      expires_at { 4.years.from_now }
    end

    person
    name { "CC - #{person.last_name1}" }
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
  end

  factory :direct_debit, class: :"payment_methods/direct_debit" do
    name { "*" * 16 + iban[-4..-1] }
    iban { Census::Faker::Bank.iban("ES") }
    bic { Faker::Bank.swift_bic }
    payment_processor { :sepa }
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
  end

  factory :orders_batch do
    description { Faker::Lorem.sentence(1, true, 4) }

    after :build do |orders_batch|
      orders_batch.orders = build_list(:order, 10, orders_batch: orders_batch) + build_list(:order, 10, :credit_card, orders_batch: orders_batch)
    end
  end
end
