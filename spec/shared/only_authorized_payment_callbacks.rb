# frozen_string_literal: true

shared_examples_for "only authorized payment callbacks" do
  describe "allow external requests to authorized payment callbacks" do
    before do
      override_ip "3.3.3.3"
    end

    it { expect(subject).not_to eq(403) }
  end

  describe "don't allow external requests to authorized api clients" do
    before do
      override_ip "1.1.1.1"
    end

    it { expect(subject).to eq(403) }
  end

  describe "don't allow external requests, except authorized payment callbacks" do
    before do
      override_ip "EXTERNAL"
    end

    it { expect(subject).to eq(403) }
  end
end
