# frozen_string_literal: true

Rails.logger.debug "Seeding cancellations"

admins = Admin.where role: [:data, :data_help]

real_now = Time.zone.now

# create 10 cancellation procedures
random_people.where.not(id: Admin.pluck(:person_id)).limit(10).each do |person|
  Timecop.freeze Faker::Time.between(3.days.ago(real_now), 1.day.ago(real_now), :between)
  PaperTrail.request.whodunnit = person
  cancellation = Procedures::Cancellation.create!(person: person,
                                                  information: { reason: Faker::Lorem.sentence, channel: %w(decidim email phone).sample },
                                                  state: :pending)
  Rails.logger.debug { "Person cancellation created for: #{cancellation.person.decorate(data_context)}" }

  current_admin = admins.sample
  Issues::CheckIssues.call(issuable: cancellation, admin: current_admin)
  if cancellation.issues_summary != :ok
    Rails.logger.debug { "Person cancellation pending: #{cancellation.person.decorate(data_context)}" }
    next
  end

  Timecop.freeze Faker::Time.between(Time.zone.now, real_now, :between)
  PaperTrail.request.whodunnit = current_admin
  UpdateProcedureJob.perform_later(procedure: cancellation, admin: current_admin)

  Rails.logger.debug { "Person cancellation accepted for: #{cancellation.person.decorate(data_context)}" }
end
