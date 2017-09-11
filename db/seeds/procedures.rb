# frozen_string_literal: true

admins = Person.first(4)
attachments_path = File.join(__dir__, "attachments")

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

  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample1.png")))
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample2.png")))

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
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample1.png")))
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample2.png")))
end

# create 10 unprocessed verifications
Person.not_verified.order("RANDOM()").limit(10).each do |person|
  verification = Procedures::VerificationDocument.create!(person: person,
                                                          information: {},
                                                          created_at: Faker::Time.between(3.days.ago, 1.day.ago, :all))
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample1.png")))
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample2.png")))
end
