# frozen_string_literal: true

Rails.logger.debug "Seeding procedures"

admins = Admin.where role: [:lopd, :lopd_help]

attachments_path = File.join(__dir__, "attachments")

real_now = Time.zone.now

# process all registrations
Procedure.all.each do |registration|
  Timecop.freeze Faker::Time.between(registration.person.created_at, 3.days.after(registration.person.created_at), :between)

  current_admin = admins.sample

  Issues::CheckIssues.call(issuable: registration, admin: current_admin)
  if registration.issues_summary != :ok
    Rails.logger.debug { "Person registration pending: #{registration.person.decorate(lopd_context)}" }
    next
  end

  PaperTrail.request.whodunnit = current_admin

  registration.assign_attributes(
    processed_by: current_admin,
    processed_at: Time.zone.now
  )
  registration.accept
  registration.save!
  Rails.logger.debug { "Person registration accepted: #{registration.person.decorate(lopd_context)}" }
end

# create 5 processed document verifications
random_people.enabled.not_verified.limit(5).each do |person|
  Timecop.freeze Faker::Time.between(person.created_at, 3.days.ago(real_now), :between)
  PaperTrail.request.whodunnit = person

  document_verification = Procedures::DocumentVerification.create!(person: person,
                                                                   information: {},
                                                                   state: :pending)

  document_verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample1.png")))
  document_verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample2.png")))
  Rails.logger.debug { "Person document verification created for: #{document_verification.person.decorate(lopd_context)}" }

  Timecop.freeze Faker::Time.between(Time.zone.now, real_now, :between)
  current_admin = admins.sample

  PaperTrail.request.whodunnit = current_admin

  document_verification.update!(
    processed_by: current_admin,
    processed_at: Time.zone.now,
    state: Faker::Boolean.boolean(0.7) ? :accepted : :rejected,
    comment: Faker::Lorem.paragraph(1, true, 2)
  )

  next unless document_verification.accepted?
  person.verify
  person.to_member if Faker::Boolean.boolean(0.5) && person.adult?
  person.save!
  Rails.logger.debug { "Person document verification accepted for: #{document_verification.person.decorate(lopd_context)}" }
end

# create 5 unprocessed document verifications
random_people.enabled.not_verified.limit(5).each do |person|
  Timecop.freeze Faker::Time.between(3.days.ago(real_now), 1.day.ago(real_now), :between)
  PaperTrail.request.whodunnit = person
  document_verification = Procedures::DocumentVerification.create!(person: person,
                                                                   information: {})
  document_verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample1.png")))
  document_verification.attachments.create!(file: File.new(File.join(attachments_path, "#{person.document_type}-sample2.png")))
  Rails.logger.debug { "Person document verification created for: #{document_verification.person.decorate(lopd_context)}" }
end

# create 5 issues for document verifications
random_procedures(Procedures::DocumentVerification).pending.limit(5).each do |document_verification|
  Timecop.freeze Faker::Time.between(document_verification.created_at, real_now, :between)
  admin = admins.sample
  PaperTrail.request.whodunnit = admin

  issue = Issues::People::AdminRemark.for(document_verification, find: false)
  issue.explanation = Faker::Lorem.paragraph(1, true, 2)
  issue.fill
  Issues::CreateIssue.call(issue: issue, admin: admin)
  Rails.logger.debug { "Issue created for document verification procedure for: #{document_verification.person.decorate(lopd_context)}" }
end
