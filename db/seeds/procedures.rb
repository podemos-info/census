# frozen_string_literal: true

Rails.logger.debug "Seeding procedures"

admins = Admin.where role: [:lopd, :lopd_help]

attachments_path = File.join(__dir__, "attachments")

real_now = Time.now

# process all registrations
Procedure.all.each do |registration|
  Timecop.freeze Faker::Time.between(registration.person.created_at, 3.days.since(registration.person.created_at), :all)

  current_admin = admins.sample

  Issues::CheckIssues.call(issuable: registration, admin: current_admin)
  if registration.has_issues?
    Rails.logger.debug { "Person registration pending: #{registration.person.decorate}" }
    next
  end

  PaperTrail.whodunnit = current_admin

  registration.assign_attributes(
    processed_by: current_admin,
    processed_at: Time.now
  )
  registration.accept
  registration.save!
  Rails.logger.debug { "Person registration accepted: #{registration.person.decorate}" }
end

# create 10 processed verifications
Person.enabled.not_verified.order("RANDOM()").limit(10).each do |person|
  Timecop.freeze Faker::Time.between(person.created_at, 3.days.ago(real_now), :all)
  PaperTrail.whodunnit = person

  verification = Procedures::VerificationDocument.create!(person: person,
                                                          information: {},
                                                          state: :pending)

  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample1.png")))
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample2.png")))
  Rails.logger.debug { "Person verification created for: #{verification.person.decorate}" }

  Timecop.freeze Faker::Time.between(Time.now, real_now, :all)
  current_admin = admins.sample

  PaperTrail.whodunnit = current_admin

  verification.update_attributes!(
    processed_by: current_admin,
    processed_at: Time.now,
    state: Faker::Boolean.boolean(0.7) ? :accepted : :rejected,
    comment: Faker::Lorem.paragraph(1, true, 2)
  )

  next unless verification.accepted?
  person.verified_by_document = true
  person.to_member if Faker::Boolean.boolean(0.5) && person.adult?
  person.save!
  Rails.logger.debug { "Person verification accepted for: #{verification.person.decorate}" }
end

# create 5 verifications with issues
Person.enabled.not_verified.order("RANDOM()").limit(5).each do |person|
  Timecop.freeze Faker::Time.between(3.days.ago(real_now), 1.days.ago(real_now), :all)
  PaperTrail.whodunnit = person
  verification = Procedures::VerificationDocument.create!(person: person,
                                                          information: {},
                                                          state: :pending)
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample1.png")))
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample2.png")))
  Rails.logger.debug { "Person verification created for: #{verification.person.decorate}" }

  Timecop.freeze Faker::Time.between(Time.now, real_now, :all)
  PaperTrail.whodunnit = admins.sample

  verification.update_attributes!(
    processed_by: PaperTrail.actor,
    processed_at: Time.now,
    state: :issues,
    comment: Faker::Lorem.paragraph(1, true, 2)
  )
  Rails.logger.debug { "Person verification with issues for: #{verification.person.decorate}" }
end

# create 10 unprocessed verifications
Person.enabled.not_verified.order("RANDOM()").limit(10).each do |person|
  Timecop.freeze Faker::Time.between(3.days.ago(real_now), 1.days.ago(real_now), :all)
  PaperTrail.whodunnit = person
  verification = Procedures::VerificationDocument.create!(person: person,
                                                          information: {})
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample1.png")))
  verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample2.png")))
  Rails.logger.debug { "Person verification created for: #{verification.person.decorate}" }
end
