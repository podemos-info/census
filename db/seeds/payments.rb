# frozen_string_literal: true

require "iban_bic/random"

admins = Admin.where role: [:finances]

def create_order(person, credit_card, campaign)
  PaperTrail.whodunnit = person
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
                currency: "EUR", amount: Faker::Number.between(1, 10_000), campaign: campaign
end

# Once upon a time...
Timecop.travel 3.years.ago

# create payees
Scope.local.children.each do |scope|
  Payee.create! scope: scope, name: "#{scope.name[:es]} payee", iban: IbanBic.random_iban(tags: [:sepa], not_tags: [:fixed_iban_check])
end

campaigns = (1..10).map do |i|
  Campaign.create! campaign_code: "DECIDIM-#{i}"
end

35.times do
  # create 10 direct debit payment methods and orders
  orders = Person.where("created_at < ?", Time.now).order("RANDOM()").limit(10).map do |person|
    create_order person, false, campaigns.sample
  end

  # create 10 direct credit card methods and orders
  orders2 = Person.where("created_at < ?", Time.now).order("RANDOM()").limit(10).map do |person|
    create_order person, true, campaigns.sample
  end

  PaperTrail.whodunnit = admins.sample
  # add orders to an order batch
  OrdersBatch.create!(
    description: I18n.l(Date.today, format: "%B %Y"),
    orders: orders + orders2
  )
  Timecop.travel 1.month.from_now
end

# create 10 direct debit payment methods and orders
Person.where("created_at < ?", Time.now).order("RANDOM()").limit(10).map do |person|
  create_order person, false, campaigns.sample
end

# create 10 direct credit card methods and orders
Person.where("created_at < ?", Time.now).order("RANDOM()").limit(10).map do |person|
  create_order person, true, campaigns.sample
end

campaigns.sample(5) do |campaign|
  campaign.update_attributes description: Faker::Lorem.sentence(1, true, 4), payee: Payee.order("RANDOM()").first
end

# Back to reality
Timecop.return
