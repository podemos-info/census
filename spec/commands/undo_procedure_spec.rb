# frozen_string_literal: true

require "rails_helper"

describe UndoProcedure do
  let(:procedure) { create(:verification_document, :undoable) }
  let(:processor) { procedure.processed_by }

  subject do
    UndoProcedure.call(procedure, processor)
  end

  describe "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "reverts procedure state" do
      expect { subject } .to change { Procedure.find(procedure.id).state } .to("pending")
    end

    it "reverts the processor" do
      expect { subject } .to change { Procedure.find(procedure.id).processed_by } .to(nil)
    end

    it "reverts processing date" do
      expect { subject } .to change { Procedure.find(procedure.id).processed_at } .to(nil)
    end

    it "reverts comment" do
      expect { subject } .to change { Procedure.find(procedure.id).comment } .to(nil)
    end

    context "on dependent procedures" do
      let(:procedure) { create(:verification_document, :with_dependent_procedure, :undoable) }
      let(:dependent_procedure) { procedure.dependent_procedures.first }

      it "reverts procedure state" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).state } .to("pending")
      end

      it "reverts processor" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).processed_by } .to(nil)
      end

      it "reverts processing date" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).processed_at } .to(nil)
      end

      it "reverts comment" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).comment } .to(nil)
      end
    end
  end

  context "when processor" do
    context "is other" do
      let!(:processor) { create(:person) }

      it "broadcasts :invalid" do
        expect { subject } .to broadcast(:invalid)
      end

      it "does not revert procedure state" do
        expect { subject } .to_not change { Procedure.find(procedure.id).state }
      end

      it "does not revert processor" do
        expect { subject } .to_not change { Procedure.find(procedure.id).processed_by }
      end

      it "does not revert processing date" do
        expect { subject } .to_not change { Procedure.find(procedure.id).processed_at }
      end

      it "does not revert comment" do
        expect { subject } .to_not change { Procedure.find(procedure.id).comment }
      end

      context "on dependent procedures" do
        let(:procedure) { create(:verification_document, :with_dependent_procedure, :undoable) }
        let(:dependent_procedure) { procedure.dependent_procedures.first }

        it "does not revert procedure state" do
          expect { subject } .to_not change { Procedure.find(dependent_procedure.id).state }
        end

        it "does not revert processor" do
          expect { subject } .to_not change { Procedure.find(dependent_procedure.id).processed_by }
        end

        it "does not revert processing date" do
          expect { subject } .to_not change { Procedure.find(dependent_procedure.id).processed_at }
        end

        it "does not revert comment" do
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
end
