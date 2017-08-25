# frozen_string_literal: true

shared_examples_for "only authorized clients" do
  context "allow external requests to authorized clients" do
    before do
      override_ip "1.1.1.1"
    end
    it { expect(subject).not_to eq(403) }
  end

  context "don't allow external requests, except authorized clients" do
    before do
      override_ip "EXTERNAL"
    end
    it { expect(subject).to eq(403) }
  end
end
