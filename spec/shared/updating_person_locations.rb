# frozen_string_literal: true

shared_examples_for "processes the new person location" do
  let(:job_messages) { ActiveJobReporter::Job.last.messages.map { |m| m.message["key"] }.uniq.sort }

  it "stores the person location" do
    expect { subject }.to change { person.person_locations.count } .by(1)
  end

  it "doesn't logs person location invalids" do
    subject
    expect(job_messages).not_to include("update_person_location.invalid")
  end

  it "doesn't logs person location errors" do
    subject
    expect(job_messages).not_to include("update_person_location.error")
  end
end

shared_examples_for "processes an invalid person location" do
  let(:job_messages) { ActiveJobReporter::Job.last.messages.map { |m| m.message["key"] }.uniq.sort }

  it "doesn't store the person location" do
    expect { subject }.not_to change(person.person_locations, :count)
  end

  it "logs an invalid person location" do
    subject
    expect(job_messages).to include("update_person_location.invalid")
  end

  it "doesn't logs person location errors" do
    subject
    expect(job_messages).not_to include("update_person_location.error")
  end
end

shared_examples_for "doesn't receive a person location" do
  let(:job_messages) { ActiveJobReporter::Job.last.messages.map { |m| m.message["key"] }.uniq.sort }

  it "doesn't store the person location" do
    expect { subject }.not_to change(person.person_locations, :count)
  end

  it "doesn't logs person location invalids" do
    subject
    expect(job_messages).not_to include("update_person_location.invalid")
  end

  it "doesn't logs person location errors" do
    subject
    expect(job_messages).not_to include("update_person_location.error")
  end
end