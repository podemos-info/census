# frozen_string_literal: true

Rails.logger.debug "Seeding people"

require "census/faker/document_id"

def register_person(use_procedure: true, copy_from_procedure: nil)
  if copy_from_procedure
    person_data = copy_from_procedure.person_data.with_indifferent_access
    person_data[:document_scope] = Scope.find(person_data[:document_scope_id])
    person_data[:address_scope] = Scope.find(person_data[:address_scope_id])
    person_data[:scope] = Scope.find(person_data[:scope_id])
  else
    local_scopes = Scope.local.descendants.leafs
    emigrant_scopes = Scope.local.not_descendants.leafs
    doc = Person.document_types.keys.sample
    young = Faker::Boolean.boolean(0.1)
    emigrant = Faker::Boolean.boolean(0.1)
    scope = local_scopes.sample

    person_data = {
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
      membership_level: :follower
    }
  end

  person = nil
  if use_procedure
    person_data[:document_scope_code] = person_data[:document_scope].code
    person_data[:address_scope_code] = person_data[:address_scope].code
    person_data[:scope_code] = person_data[:scope].code
    People::CreateRegistration.call(form: People::RegistrationForm.from_params(person_data)) do
      on(:ok) do |info|
        person = info[:person]
        Rails.logger.debug { "Person registered: #{person.decorate}" }
      end
      on(:invalid) { Rails.logger.warn { "Invalid data for person registration: #{person_data.as_json}" } }
      on(:error) { Rails.logger.warn { "Error registering person: #{person_data.as_json}" } }
    end
  else
    person = Person.create!(person_data)
    Rails.logger.debug { "Person created: #{person.decorate}" }
  end
  person
end

# Once upon a time...
Timecop.travel 3.years.ago

Admin.roles.each_key do |role|
  2.times do |i|
    person = register_person(use_procedure: false)
    PaperTrail.whodunnit = person
    person.update_attributes verified_in_person: true
    admin = Admin.create! username: "#{role}#{i}", password: role, password_confirmation: role, person: person, role: role
    Rails.logger.debug { "Admin '#{admin.username}' created for person: #{person.decorate}" }
  end
  Timecop.travel 1.month.from_now
end

# create persons
34.times do
  register_person
  Timecop.travel 1.month.from_now
end

# create some duplicated person procedures
Procedure.order("RANDOM()").limit(3).each do |procedure|
  register_person(copy_from_procedure: procedure)
end

# Back to reality
Timecop.return
