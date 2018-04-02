# frozen_string_literal: true

Rails.logger.debug "Seeding payments"

require "iban_bic/random"

admins = Admin.where role: [:finances]

def random_people
  Person.where("created_at < ?", Time.zone.now).order("RANDOM()")
end

def create_order(person, credit_card, campaign)
  PaperTrail.request.whodunnit = person
  payment_method = person.payment_methods.where(type: "PaymentMethods::#{credit_card ? "CreditCard" : "DirectDebit"}").sample
  payment_method ||= if credit_card
                       expires_at = Faker::Date.between(6.months.ago, 4.years.from_now)
                       PaymentMethods::CreditCard.new person: person, payment_processor: :redsys,
                                                      authorization_token: "invalid code", expiration_year: expires_at.year, expiration_month: expires_at.month
                     else
                       PaymentMethods::DirectDebit.new person: person, payment_processor: :sepa, iban: IbanBic.random_iban(tags: [:sepa], not_tags: [:fixed_iban_check])
                     end
  Payments::SavePaymentMethod.call(payment_method: payment_method, admin: nil)

  order = Order.create! person: person, payment_method: payment_method,
                        description: Faker::Lorem.sentence(1, true, 4),
                        currency: "EUR", amount: Faker::Number.between(1, 10_000), campaign: campaign
  Rails.logger.debug { "Orders created: #{order.decorate}" }
  order
end

# Once upon a time...
Timecop.travel 2.years.ago

# create payees
Scope.local.children.each do |scope|
  payee = Payee.create! scope: scope, name: "#{scope.name["es"]} payee", iban: IbanBic.random_iban(tags: [:sepa], not_tags: [:fixed_iban_check])
  Rails.logger.debug { "Payee create: #{payee.decorate}" }
end

campaigns = (1..10).map do |i|
  campaign = Campaign.create! campaign_code: "DECIDIM-#{i}"
  Rails.logger.debug { "Campaign created: #{campaign.decorate}" }
  campaign
end

23.times do
  # create 10 direct debit payment methods and orders
  orders = random_people.limit(10).map do |person|
    create_order person, false, campaigns.sample
  end

  # create 10 direct credit card methods and orders
  orders2 = random_people.limit(10).map do |person|
    create_order person, true, campaigns.sample
  end

  PaperTrail.request.whodunnit = admins.sample
  # add orders to an order batch
  orders_batch = OrdersBatch.create!(
    description: I18n.l(Time.zone.today, format: "%B %Y"),
    orders: orders + orders2
  )
  Rails.logger.debug { "Orders batch created: #{orders_batch.decorate}" }
  Timecop.travel 1.month.from_now
end

# create 10 direct debit payment methods and orders
random_people.limit(10).map do |person|
  create_order person, false, campaigns.sample
end

# create 10 direct credit card methods and orders
random_people.limit(10).map do |person|
  create_order person, true, campaigns.sample
end

campaigns.sample(5) do |campaign|
  campaign.update! description: Faker::Lorem.sentence(1, true, 4), payee: Payee.order("RANDOM()").first
end

# Back to reality
Timecop.return
