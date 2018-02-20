# frozen_string_literal: true

require "rails_helper"

describe Procedures::ProcessProcedure do
  subject(:process_procedure) { described_class.call(form) }

  let!(:procedure) { create(:document_verification) }
  let(:event) { :accept }
  let(:comment) { "This is a comment" }
  let!(:admin) { create(:admin) }
  let(:form_class) { Procedures::ProcessForm }
  let(:valid) { true }

  let(:form) do
    instance_double(
      form_class,
      invalid?: !valid,
      valid?: valid,
      procedure: procedure,
      admin: admin,
      event: event,
      comment: comment
    )
  end

  describe "when valid" do
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

    context "on dependent procedures" do
      let!(:procedure) { create(:document_verification, :with_dependent_procedure) }
      let(:dependent_procedure) { procedure.dependent_procedures.first }

      it "updates procedure state" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).state } .from("pending").to("accepted")
      end

      it "sets processed_by" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).processed_by } .to(admin)
      end

      it "sets processing date" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).processed_at }
      end

      it "updates comment" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).comment } .to("This is a comment")
      end
    end
  end

  context "when form is invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "does not update procedure state" do
      expect { subject } .to_not change { Procedure.find(procedure.id).state }
    end

    it "does not set processed_by" do
      expect { subject } .to_not change { Procedure.find(procedure.id).processed_by }
    end

    it "does not set processing date" do
      expect { subject } .to_not change { Procedure.find(procedure.id).processed_at }
    end

    it "does not update comment" do
      expect { subject } .to_not change { Procedure.find(procedure.id).comment }
    end

    context "on dependent procedures" do
      let(:procedure) { create(:document_verification, :with_dependent_procedure) }
      let(:dependent_procedure) { procedure.dependent_procedures.first }

      it "does not update procedure state" do
        expect { subject } .to_not change { Procedure.find(dependent_procedure.id).state }
      end

      it "does not set processed_by" do
        expect { subject } .to_not change { Procedure.find(dependent_procedure.id).processed_by }
      end

      it "does not set processing date" do
        expect { subject } .to_not change { Procedure.find(dependent_procedure.id).processed_at }
      end

      it "does not update comment" do
        expect { subject } .to_not change { Procedure.find(dependent_procedure.id).comment }
      end
    end
  end

  context "when procedure can't be saved because is invalid" do
    before { allow(procedure).to receive(:invalid?).and_return(true) }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "does not update procedure state" do
      expect { subject } .to_not change { Procedure.find(procedure.id).state }
    end

    it "does not set processed_by" do
      expect { subject } .to_not change { Procedure.find(procedure.id).processed_by }
    end

    it "does not set processing date" do
      expect { subject } .to_not change { Procedure.find(procedure.id).processed_at }
    end

    it "does not update comment" do
      expect { subject } .to_not change { Procedure.find(procedure.id).comment }
    end
  end
end
