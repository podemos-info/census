# frozen_string_literal: true

require "iban_bic/random"

def create_order(person, credit_card)
  PaperTrail.whodunnit = person
  Timecop.travel Faker::Time.between(3.years.ago, 3.day.ago, :all) do
    payment_method = if credit_card
                       expires_at = Faker::Date.between(6.month.ago, 4.year.from_now)
                       PaymentMethods::CreditCard.new person: person, payment_processor: :redsys,
                                                      authorization_token: "invalid code", expiration_year: expires_at.year, expiration_month: expires_at.month
                     else
                       PaymentMethods::DirectDebit.new person: person, payment_processor: :sepa, iban: IbanBic.random_iban(tags: [:sepa], not_tags: [:fixed_iban_check])
                     end
    payment_method.decorate.save!

    Order.create! person: person, payment_method: payment_method,
                  description: Faker::Lorem.sentence(1, true, 4),
                  currency: "EUR", amount: Faker::Number.between(1, 10_000)
  end
end

3.times do
  # create 10 direct debit payment methods and orders
  orders = Person.verified.order("RANDOM()").limit(10).map do |person|
    create_order person, false
  end

  # create 10 direct credit card methods and orders
  orders2 = Person.verified.order("RANDOM()").limit(10).map do |person|
    create_order person, true
  end

  PaperTrail.whodunnit = Admin.first
  # add orders to an order batch
  OrdersBatch.create!(
    description: Faker::Lorem.sentence(1, true, 4),
    orders: orders + orders2
  )
end
