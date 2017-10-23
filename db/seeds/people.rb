# frozen_string_literal: true

require "census/faker/document_id"

def create_person
  local_scopes = Scope.local.descendants.leafs
  emigrant_scopes = Scope.local.not_descendants.leafs
  doc = Person.document_types.keys.sample
  young = Faker::Boolean.boolean(0.1)
  emigrant = Faker::Boolean.boolean(0.1)
  scope = local_scopes.sample

  person = Person.create!(
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
    scope: scope
  )
  person.versions.first.update_attributes(whodunnit: person)
  person
end

Timecop.travel 3.years.ago do
  Admin.roles.each_key do |role|
    2.times do |i|
      person = create_person
      PaperTrail.whodunnit = person
      person.update_attributes verified_in_person: true
      Admin.create! username: "#{role}#{i}", password: role, password_confirmation: role, person: person, role: role
    end
    Timecop.travel 1.month.from_now
  end

  35.times do
    create_person
    Timecop.travel 1.month.from_now
  end
end
