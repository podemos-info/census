# frozen_string_literal: true

require "census/faker/document_id"

local_scopes = Scope.local.descendants.leafs
emigrant_scopes = Scope.local.not_descendants.leafs

30.times do
  doc = Person.document_types.keys.sample
  young = Faker::Boolean.boolean(0.1)
  emigrant = Faker::Boolean.boolean(0.1)
  scope = local_scopes.sample

  Person.create!(
    first_name: Faker::Name.first_name,
    last_name1: Faker::Name.last_name,
    last_name2: Faker::Name.last_name,
    document_type: doc,
    document_id: Census::Faker::DocumentId.generate(doc),
    document_scope: doc == "passport" ? Scope.top_level.sample : Scope.local,
    born_at: young ? Faker::Date.between(18.year.ago, 14.year.ago) : Faker::Date.between(99.year.ago, 18.year.ago),
    gender: Person.genders.keys.sample,
    address: Faker::Address.street_address,
    address_scope: emigrant ? emigrant_scopes.sample : scope,
    postal_code: Faker::Address.zip_code,
    email: Faker::Internet.unique.email,
    phone: "0034" + Faker::Number.number(9),
    scope: scope,
    created_at: Faker::Time.between(3.years.ago, 3.day.ago, :all)
  )
end

# create and verify 4 admins
admins = Person.first(4)
admins.each do |admin|
  admin.update_attributes verified_in_person: true
end