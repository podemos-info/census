# frozen_string_literal: true

Rails.logger.debug "Seeding procedures"

admins = Admin.where role: [:lopd, :lopd_help]

attachments_path = File.join(__dir__, "attachments")

real_now = Time.zone.now

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
    processed_at: Time.zone.now
  )
  registration.accept
  registration.save!
  Rails.logger.debug { "Person registration accepted: #{registration.person.decorate}" }
end

# create 10 processed document verifications
Person.enabled.not_verified.order("RANDOM()").limit(10).each do |person|
  Timecop.freeze Faker::Time.between(person.created_at, 3.days.ago(real_now), :all)
  PaperTrail.whodunnit = person

  document_verification = Procedures::DocumentVerification.create!(person: person,
                                                                   information: {},
                                                                   state: :pending)

  document_verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample1.png")))
  document_verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample2.png")))
  Rails.logger.debug { "Person document verification created for: #{document_verification.person.decorate}" }

  Timecop.freeze Faker::Time.between(Time.zone.now, real_now, :all)
  current_admin = admins.sample

  PaperTrail.whodunnit = current_admin

  document_verification.update_attributes!(
    processed_by: current_admin,
    processed_at: Time.zone.now,
    state: Faker::Boolean.boolean(0.7) ? :accepted : :rejected,
    comment: Faker::Lorem.paragraph(1, true, 2)
  )

  next unless document_verification.accepted?
  person.verified_by_document = true
  person.to_member if Faker::Boolean.boolean(0.5) && person.adult?
  person.save!
  Rails.logger.debug { "Person document verification accepted for: #{document_verification.person.decorate}" }
end

# create 5 document verifications with issues
Person.enabled.not_verified.order("RANDOM()").limit(5).each do |person|
  Timecop.freeze Faker::Time.between(3.days.ago(real_now), 1.day.ago(real_now), :all)
  PaperTrail.whodunnit = person
  document_verification = Procedures::DocumentVerification.create!(person: person,
                                                                   information: {},
                                                                   state: :pending)
  document_verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample1.png")))
  document_verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample2.png")))
  Rails.logger.debug { "Person document verification created for: #{document_verification.person.decorate}" }

  Timecop.freeze Faker::Time.between(Time.zone.now, real_now, :all)
  PaperTrail.whodunnit = admins.sample

  document_verification.update_attributes!(
    processed_by: PaperTrail.actor,
    processed_at: Time.zone.now,
    state: :issues,
    comment: Faker::Lorem.paragraph(1, true, 2)
  )
  Rails.logger.debug { "Person document verification with issues for: #{document_verification.person.decorate}" }
end

# create 10 unprocessed document verifications
Person.enabled.not_verified.order("RANDOM()").limit(10).each do |person|
  Timecop.freeze Faker::Time.between(3.days.ago(real_now), 1.day.ago(real_now), :all)
  PaperTrail.whodunnit = person
  document_verification = Procedures::DocumentVerification.create!(person: person,
                                                                   information: {})
  document_verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample1.png")))
  document_verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample2.png")))
  Rails.logger.debug { "Person document verification created for: #{document_verification.person.decorate}" }
end
