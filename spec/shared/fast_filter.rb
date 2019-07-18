# frozen_string_literal: true

shared_examples_for "a controller that allows fast filter" do
  context "when it finds anything" do
    let(:params) { { ff: fast_filter } }

    it { is_expected.to be_successful }

    it "includes the result" do
      subject
      expect(response.body).to include(result)
    end
  end

  context "when it doesn't finds anything" do
    let(:params) { { ff: "a really difficult to find search text" } }

    it { is_expected.to be_successful }

    it "doesn't include the result" do
      subject
      expect(response.body).not_to include(result)
    end
  end
end

shared_examples_for "a model that allows fast filter" do |cases|
  describe "#fast_filter" do
    subject(:filtering) { described_class.apply_fast_filter(text) }

    before { resource }

    cases.each do |filter, text_proc|
      context "when filtering by #{filter.to_s.humanize.downcase}" do
        let(:text) { text_proc.call(resource) }

        it { is_expected.to eq([resource]) }
      end
    end

    context "when filtering by a random string" do
      let(:text) { "a really difficult to find search text" }

      it { is_expected.to be_empty }
    end
  end
end
