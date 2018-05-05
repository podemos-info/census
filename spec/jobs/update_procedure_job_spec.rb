# frozen_string_literal: true

require "rails_helper"

describe UpdateProcedureJob, type: :job do
  subject(:job) { described_class.perform_now(procedure: procedure, admin: current_admin) }

  shared_examples_for "an update procedure job" do
    context "when everything works ok" do
      let(:procedure) { create(:registration) }
      let(:person) { procedure.person }

      it "completes the job" do
        expect { subject } .to change { job_for(procedure)&.result } .from(nil).to("ok")
      end

      it "accepts the new person" do
        expect { subject }.to change { person.reload.state }.from("pending").to("enabled")
      end
    end

    context "when a person with an open issue is cancelled" do
      let!(:open_issue) { create(:duplicated_document) }
      let(:registration_procedure) { open_issue.procedures.first }
      let(:person) { registration_procedure.person }
      let(:procedure) { create(:cancellation, person: person) }

      it "completes the job" do
        expect { subject } .to change { job_for(procedure)&.result } .from(nil).to("ok")
      end

      it "doesn't create new issues" do
        expect { subject } .not_to change { Issue.count }
      end

      it "closes the existing issue" do
        expect { subject } .to change { open_issue.reload.closed_at } .from(nil)
      end

      it "keeps the issue related objects before fixing it" do
        expect { subject } .not_to change { open_issue.reload.people }
      end
    end

    context "when a person related to an open issue is cancelled" do
      let!(:open_issue) { create(:duplicated_document, other_person: other_person) }
      let(:registration_procedure) { open_issue.procedures.first }
      let(:person) { registration_procedure.person }
      let(:other_person) { create(:person) }
      let(:procedure) { create(:cancellation, person: other_person) }

      it "completes the job" do
        expect { subject } .to change { job_for(procedure)&.result } .from(nil).to("ok")
      end

      it "doesn't create new issues" do
        expect { subject } .not_to change { Issue.count }
      end

      it "closes the existing issue" do
        expect { subject } .to change { open_issue.reload.closed_at } .from(nil)
      end

      it "keeps the issue related objects before fixing it" do
        expect { subject } .not_to change { open_issue.reload.people }
      end
    end
  end

  context "when explicity processing" do
    let(:current_admin) { create(:admin, :data) }

    it_behaves_like "an update procedure job"
  end

  context "when auto processing" do
    let(:current_admin) { nil }

    it_behaves_like "an update procedure job"
  end
end
