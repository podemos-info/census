# frozen_string_literal: true

require "census/faker/bank"

3.times do
  # create 10 direct debit payment methods and orders
  orders = Person.verified.order("RANDOM()").limit(10).map do |person|
    iban = Census::Faker::Bank.iban("ES")
    payment_method = PaymentMethods::DirectDebit.create!(
      person: person,
      name: "*" * 16 + iban[-4..-1],
      iban: iban,
      bic: Faker::Bank.swift_bic,
      payment_processor: :sepa
    )

    Order.create!(
      person: person,
      payment_method: payment_method,
      currency: "EUR",
      amount: Faker::Number.between(1, 10_000),
      description: Faker::Lorem.sentence(1, true, 4)
    )
  end

  # create 10 direct credit card methods and orders
  orders2 = Person.verified.order("RANDOM()").limit(10).map do |person|
    expires_at = Faker::Date.between(6.month.ago, 4.year.from_now)
    payment_method = PaymentMethods::CreditCard.create!(
      person: person,
      name: "CC - #{person.last_name1}",
      authorization_token: "PATATAT!",
      expiration_year: expires_at.year,
      expiration_month: expires_at.month,
      payment_processor: :redsys
    )

    Order.create!(
      person: person,
      payment_method: payment_method,
      currency: "EUR",
      amount: Faker::Number.between(1, 10_000),
      description: Faker::Lorem.sentence(1, true, 4)
    )
  end

  # add orders to an order batch
  OrdersBatch.create!(
    description: Faker::Lorem.sentence(1, true, 4),
    orders: orders + orders2
  )
end
