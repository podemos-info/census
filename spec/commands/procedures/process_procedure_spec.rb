# frozen_string_literal: true

require "rails_helper"

describe Procedures::ProcessProcedure do
  subject(:process_procedure) { described_class.call(form: form, admin: admin) }

  let!(:procedure) { create(:document_verification) }
  let(:action) { :accept }
  let(:comment) { "This is a comment" }
  let!(:admin) { create(:admin) }
  let(:form_class) { Procedures::ProcessProcedureForm }
  let(:valid) { true }

  let(:form) do
    instance_double(
      form_class,
      adding_issue?: action == :issue,
      accepting?: action == :accept,
      invalid?: !valid,
      valid?: valid,
      procedure: procedure,
      processed_by: admin,
      action: action,
      comment: comment
    )
  end

  context "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "updates procedure state" do
      expect { subject } .to change { Procedure.find(procedure.id).state } .from("pending").to("accepted")
    end

    it "sets processed_by" do
      expect { subject } .to change { Procedure.find(procedure.id).processed_by } .to(admin)
    end

    it "sets processing date" do
      expect { subject } .to change { Procedure.find(procedure.id).processed_at }
    end

    it "updates comment" do
      expect { subject } .to change { Procedure.find(procedure.id).comment } .to("This is a comment")
    end
  end

  context "when adding an issue" do
    let(:action) { :issue }

    it "broadcasts :issue_ok" do
      expect { subject } .to broadcast(:issue_ok)
    end

    it "adds a new issue" do
      expect { subject } .to change { Issues::People::AdminRemark.count } .from(0).to(1)
    end

    describe "the created issue" do
      subject(:created_issue) do
        process_procedure
        Issues::People::AdminRemark.last
      end

      it { is_expected.to be_open }

      it "is related to the procedure" do
        expect(subject.procedures.first).to eq(procedure)
      end

      it "has the given comment as explanation" do
        expect(subject.explanation).to eq(comment)
      end
    end

    it "doesn't updates procedure state" do
      expect { subject } .not_to change { Procedure.find(procedure.id).state } .from("pending")
    end

    it "doesn't sets processed_by" do
      expect { subject } .not_to change { Procedure.find(procedure.id).processed_by }
    end

    it "doesn't sets processing date" do
      expect { subject } .not_to change { Procedure.find(procedure.id).processed_at }
    end

    it "doesn't updates comment" do
      expect { subject } .not_to change { Procedure.find(procedure.id).comment }
    end
  end

  context "when form is invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "does not update procedure state" do
      expect { subject } .not_to change { Procedure.find(procedure.id).state }
    end

    it "does not set processed_by" do
      expect { subject } .not_to change { Procedure.find(procedure.id).processed_by }
    end

    it "does not set processing date" do
      expect { subject } .not_to change { Procedure.find(procedure.id).processed_at }
    end

    it "does not update comment" do
      expect { subject } .not_to change { Procedure.find(procedure.id).comment }
    end
  end

  context "when procedure can't be saved because is invalid" do
    before { allow(procedure).to receive(:valid?).and_return(false) }

    it "broadcasts :error" do
      expect { subject } .to broadcast(:error)
    end

    it "does not update procedure state" do
      expect { subject } .not_to change { Procedure.find(procedure.id).state }
    end

    it "does not set processed_by" do
      expect { subject } .not_to change { Procedure.find(procedure.id).processed_by }
    end

    it "does not set processing date" do
      expect { subject } .not_to change { Procedure.find(procedure.id).processed_at }
    end

    it "does not update comment" do
      expect { subject } .not_to change { Procedure.find(procedure.id).comment }
    end
  end
end
