# frozen_string_literal: true

shared_context "hutch notifications", shared_context: :metadata do
  before { Hutch.connect }
  after { Hutch.disconnect }

  it "publish the notification" do
    notification = try(:publish_notification)

    if notification
      expect(Hutch.broker.exchange).to receive(:publish).once.with(
        JSON.dump(notification[:parameters]),
        hash_including(
          persistent: true,
          routing_key: notification[:routing_key],
          content_type: "application/json"
        )
      )
    else
      expect(Hutch.broker.exchange).not_to receive(:publish)
    end
    subject
  end
end
