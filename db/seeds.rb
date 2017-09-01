# frozen_string_literal: true

require "census/seeds/scopes"

# don't seed on Continuous Integration
return if ENV["CI"]

base_path = File.expand_path("seeds", __dir__)
if Rails.env.production?
  Census::Seeds::Scopes.seed base_path: base_path
else
  require "census/faker/document_id"

  Census::Seeds::Scopes.seed(base_path: base_path) unless Scope.count.positive?

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

  admins = Person.first(10)

  # create 10 processed verifications
  Person.not_verified.order("RANDOM()").limit(10).each do |person|
    date = Faker::Time.between(person.created_at, 3.day.ago, :all)
    verification = Procedures::VerificationDocument.create!(person: person,
                                                            information: {},
                                                            created_at: date,
                                                            processed_by: admins.sample,
                                                            processed_at: Faker::Time.between(date, DateTime.now, :all),
                                                            state: Faker::Boolean.boolean(0.7) ? :accepted : :rejected,
                                                            comment: Faker::Lorem.paragraph(1, true, 2))

    verification.attachments.create!(file: File.new(File.join(__dir__, "seeds", "attachments", "#{person.document_type}-sample1.png")))
    verification.attachments.create!(file: File.new(File.join(__dir__, "seeds", "attachments", "#{person.document_type}-sample2.png")))

    person.verified_by_document = true
    person.updated_at = verification.processed_at
    person.to_member if Faker::Boolean.boolean(0.5)
    person.save
  end

  # create 5 verifications with issues
  Person.not_verified.order("RANDOM()").limit(5).each do |person|
    verification = Procedures::VerificationDocument.create!(person: person,
                                                            information: {},
                                                            created_at: Faker::Time.between(3.days.ago, 1.day.ago, :all),
                                                            state: :issues,
                                                            comment: Faker::Lorem.paragraph(1, true, 2))
    verification.attachments.create!(file: File.new(File.join(__dir__, "seeds", "attachments", "#{person.document_type}-sample1.png")))
    verification.attachments.create!(file: File.new(File.join(__dir__, "seeds", "attachments", "#{person.document_type}-sample2.png")))
  end

  # create 10 unprocessed verifications
  Person.not_verified.order("RANDOM()").limit(10).each do |person|
    verification = Procedures::VerificationDocument.create!(person: person,
                                                            information: {},
                                                            created_at: Faker::Time.between(3.days.ago, 1.day.ago, :all))
    verification.attachments.create!(file: File.new(File.join(__dir__, "seeds", "attachments", "#{person.document_type}-sample1.png")))
    verification.attachments.create!(file: File.new(File.join(__dir__, "seeds", "attachments", "#{person.document_type}-sample2.png")))
  end
end
