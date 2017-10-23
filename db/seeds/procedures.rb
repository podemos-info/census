# frozen_string_literal: true

admins = Admin.where role: [:lopd, :lopd_help]

attachments_path = File.join(__dir__, "attachments")

real_now = Time.now

# create 10 processed verifications
Person.not_verified.order("RANDOM()").limit(10).each do |person|
  Timecop.freeze Faker::Time.between(person.created_at, 3.days.ago(real_now), :all)
  PaperTrail.whodunnit = person

  verification = Procedures::VerificationDocument.create!(person: person,
                                                          information: {},
                                                          state: :pending)

  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample1.png")))
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample2.png")))

  Timecop.freeze Faker::Time.between(Time.now, real_now, :all)
  PaperTrail.whodunnit = admins.sample

  verification.update_attributes!(
    processed_by: PaperTrail.actor,
    processed_at: Time.now,
    state: Faker::Boolean.boolean(0.7) ? :accepted : :rejected,
    comment: Faker::Lorem.paragraph(1, true, 2)
  )

  next if verification.accepted?
  person.verified_by_document = true
  person.to_member if Faker::Boolean.boolean(0.5)
  person.save
end

# create 5 verifications with issues
Person.not_verified.order("RANDOM()").limit(5).each do |person|
  Timecop.freeze Faker::Time.between(3.days.ago(real_now), 1.days.ago(real_now), :all)
  PaperTrail.whodunnit = person
  verification = Procedures::VerificationDocument.create!(person: person,
                                                          information: {},
                                                          state: :pending)
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample1.png")))
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample2.png")))

  Timecop.freeze Faker::Time.between(Time.now, real_now, :all)
  PaperTrail.whodunnit = admins.sample

  verification.update_attributes!(
    processed_by: PaperTrail.actor,
    processed_at: Time.now,
    state: :issues,
    comment: Faker::Lorem.paragraph(1, true, 2)
  )
end

# create 10 unprocessed verifications
Person.not_verified.order("RANDOM()").limit(10).each do |person|
  Timecop.freeze Faker::Time.between(3.days.ago(real_now), 1.days.ago(real_now), :all)
  PaperTrail.whodunnit = person
  verification = Procedures::VerificationDocument.create!(person: person,
                                                          information: {})
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample1.png")))
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample2.png")))
end
