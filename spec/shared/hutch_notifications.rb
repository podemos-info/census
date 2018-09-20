# frozen_string_literal: true

shared_context "when connected to hutch" do
  before { Hutch.connect }

  after { Hutch.disconnect }
end

shared_examples_for "an event notifiable with hutch" do
  include_context "when connected to hutch"

  it "publishes the notification" do
    expect(Hutch).to receive(:publish).once.with(*publish_notification)

    subject
  end
end

shared_examples_for "an event not notifiable with hutch" do
  include_context "when connected to hutch"

  it "does not publish any notification" do
    expect(Hutch).not_to receive(:publish)

    subject
  end
end
