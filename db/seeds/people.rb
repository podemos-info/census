# frozen_string_literal: true

Rails.logger.debug "Seeding people"

require "faker/spanish_document"

def decidim_identifier
  @decidim_identifier ||= 0
  @decidim_identifier += 1
end

def data_context
  @data_context ||= { context: { current_admin: Admin.new(role: :data) } }
end

def random_person_data(params)
  local_scopes = Scope.local.descendants.leafs
  emigrant_scopes = Scope.local.not_descendants.leafs
  doc = if Faker::Boolean.boolean(0.75)
          :dni
        else
          Faker::Boolean.boolean(0.5) ? :nie : :passport
        end
  young = params.fetch(:young, Faker::Boolean.boolean(0.1))
  emigrant = Faker::Boolean.boolean(0.1)
  scope = local_scopes.sample

  postal_code = if emigrant
                  Faker::Address.zip_code
                else
                  "#{scope.part_of_scopes.map { |s| s.mappings["INE-PROV"] } .compact.first}#{Faker::Number.number(3)}"
                end

  {
    first_name: Faker::Name.first_name,
    last_name1: Faker::Name.last_name,
    last_name2: Faker::Name.last_name,
    document_type: doc,
    document_id: Faker::SpanishDocument.generate(doc),
    document_scope: doc == "passport" ? Scope.top_level.sample : Scope.local,
    born_at: young ? Faker::Date.between(15.years.ago, 14.years.ago) : Faker::Date.between(99.years.ago, 18.years.ago),
    gender: Person.genders.keys.sample,
    address: Faker::Address.street_address,
    address_scope: emigrant ? emigrant_scopes.sample : scope,
    postal_code: postal_code,
    email: Faker::Internet.unique.email,
    phone: "0034" + Faker::Number.number(9),
    scope: scope,
    membership_level: :follower,
    state: :enabled
  }
end

def register_person(use_procedure: true, copy_from_procedure: nil, untrusted: nil, random_person_params: {})
  if copy_from_procedure
    person_data = copy_from_procedure.person_data.with_indifferent_access
    person_data[:document_scope] = Scope.find(person_data[:document_scope_id])
    person_data[:address_scope] = Scope.find(person_data[:address_scope_id])
    person_data[:scope] = Scope.find(person_data[:scope_id])
  else
    person_data = random_person_data(random_person_params)
  end

  case untrusted
  when :phone then person_data[:phone] = Issues::People::UntrustedPhone.phones_blacklist.first
  when :phone_prefix then person_data[:phone] = Issues::People::UntrustedPhone.prefixes_blacklist.first + "012345"
  when :email then person_data[:email] = "#{Faker::Internet.user_name(person_data[:first_name])}@#{Issues::People::UntrustedEmail.domains_blacklist.first}"
  end

  person = nil
  if use_procedure
    person_data[:document_scope_code] = person_data[:document_scope].code
    person_data[:address_scope_code] = person_data[:address_scope].code
    person_data[:scope_code] = person_data[:scope].code
    person_data[:origin_qualified_id] = "#{decidim_identifier}@participa2_application-1"

    People::CreateRegistration.call(form: People::RegistrationForm.from_params(person_data)) do
      on(:ok) do |info|
        person = info[:person]
        Rails.logger.debug { "Person registered: #{person.decorate(data_context)}" }
      end
      on(:invalid) { Rails.logger.warn { "Invalid data for person registration: #{person_data.as_json}" } }
      on(:error) { Rails.logger.warn { "Error registering person: #{person_data.as_json}" } }
    end
  else
    person_data[:external_ids] = { decidim: decidim_identifier }
    person = Person.create!(person_data)
    Rails.logger.debug { "Person created: #{person.decorate(data_context)}" }
  end
  person
end

# Once upon a time...
Timecop.travel 3.years.ago

# 1. Not canceled adult follower person
register_person random_person_params: { young: false }

# 2. Not canceled adult member person (will be membered later)
register_person random_person_params: { young: false }

# 3. Not canceled young person
register_person random_person_params: { young: true }

# 4. Canceled person (will be canceled later)
register_person

# 5 to 14. Regular adult people for tests
10.times do
  register_person random_person_params: { young: false }
end

Admin.roles.each_key do |role|
  2.times do |i|
    person = register_person(use_procedure: false)
    PaperTrail.request.whodunnit = person
    person.verify!
    admin = Admin.create! username: "#{role}#{i}", password: "#{ENV["SEED_PASSWORDS_PREFIX"]}#{role}", password_confirmation: role, person: person, role: role
    Rails.logger.debug { "Admin '#{admin.username}' created for person: #{person.decorate(data_context)}" }
  end
end
Timecop.travel 1.month.from_now

# create people
34.times do
  register_person
  Timecop.travel 1.month.from_now
end

# create some duplicated person procedures
random_procedures.limit(3).each do |procedure|
  register_person(copy_from_procedure: procedure)
end

# create people with untrusted data
register_person untrusted: :phone
register_person untrusted: :phone_prefix
register_person untrusted: :email

# request verification to some random people
random_people(10, scopes: [:enabled, :not_verified]).each do |person|
  person.request_verification!
  Rails.logger.debug { "Requested document verification for: #{person.decorate(data_context)}" }
end

# Back to reality
Timecop.return
