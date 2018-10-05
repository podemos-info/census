# frozen_string_literal: true

require "rails_helper"

describe People::SmsSender do
  let(:message) { "hola manola" }

  describe "#send_message" do
    subject(:method) { described_class.send_message(phone, message) }

    let(:phone) { build(:person).phone }

    it_behaves_like "an SMS is sent" do
      let(:to) { phone }
      let(:body) { message }
    end

    context "when there is no account configured" do
      it_behaves_like "an SMS is not sent" do
        let(:sms_service_username) { nil }
      end
    end
  end
end
