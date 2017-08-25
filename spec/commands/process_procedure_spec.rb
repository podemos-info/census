# frozen_string_literal: true

require "rails_helper"

describe ProcessProcedure do
  let!(:procedure) { create(:verification_document) }
  let(:event) { :accept }
  let(:params) { { event: event, comment: "This is a comment" } }
  let!(:processor) { create(:person) }

  subject do
    ProcessProcedure.call(procedure, processor, params)
  end

  describe "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "updates procedure state" do
      expect { subject } .to change { Procedure.find(procedure.id).state } .from("pending").to("accepted")
    end

    it "sets processor" do
      expect { subject } .to change { Procedure.find(procedure.id).processed_by } .to(processor)
    end

    it "sets processing date" do
      expect { subject } .to change { Procedure.find(procedure.id).processed_at }
    end

    it "updates comment" do
      expect { subject } .to change { Procedure.find(procedure.id).comment } .to("This is a comment")
    end

    context "on dependent procedures" do
      let!(:procedure) { create(:verification_document, :with_dependent_procedure) }
      let(:dependent_procedure) { procedure.dependent_procedures.first }

      it "updates procedure state" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).state } .from("pending").to("accepted")
      end

      it "sets processor" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).processed_by } .to(processor)
      end

      it "sets processing date" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).processed_at }
      end

      it "updates comment" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).comment } .to("This is a comment")
      end
    end
  end

  context "when processor" do
    context "is null" do
      let(:processor) { nil }

      it "broadcasts :invalid" do
        expect { subject } .to broadcast(:invalid)
      end

      it "does not update procedure state" do
        expect { subject } .to_not change { Procedure.find(procedure.id).state }
      end

      it "does not set processor" do
        expect { subject } .to_not change { Procedure.find(procedure.id).processed_by }
      end

      it "does not set processing date" do
        expect { subject } .to_not change { Procedure.find(procedure.id).processed_at }
      end

      it "does not update comment" do
        expect { subject } .to_not change { Procedure.find(procedure.id).comment }
      end

      context "on dependent procedures" do
        let(:processor) { nil }
        let(:procedure) { create(:verification_document, :with_dependent_procedure) }
        let(:dependent_procedure) { procedure.dependent_procedures.first }

        it "does not update procedure state" do
          expect { subject } .to_not change { Procedure.find(dependent_procedure.id).state }
        end

        it "does not set processor" do
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

    context "is the affected person" do
      let(:processor) { procedure.person }
      it "broadcasts :invalid" do
        expect { subject }.to broadcast(:invalid)
      end
    end
  end

  context "when event" do
    context "doesn't exists" do
      let(:event) { :potato }
      it "broadcasts :invalid" do
        expect { subject }.to broadcast(:invalid)
      end
    end

    context "is undo" do
      let(:event) { :undo }
      it "broadcasts :invalid" do
        expect { subject }.to broadcast(:invalid)
      end
    end

    context "is not applicable" do
      let(:event) { :pending }
      it "broadcasts :invalid" do
        expect { subject }.to broadcast(:invalid)
      end
    end
  end
end
