# frozen_string_literal: true

require "rails_helper"

describe Procedures::UndoProcedure do
  with_versioning do
    subject(:undo_procedure) { described_class.call(procedure: procedure, admin: admin) }

    let(:procedure) { create(:document_verification, :undoable) }
    let(:admin) { procedure.processed_by }

    context "when undoing an accepted procedure" do
      it "broadcasts :ok" do
        expect { subject } .to broadcast(:ok)
      end

      it "reverts procedure state" do
        expect { subject } .to change { Procedure.find(procedure.id).state } .to("pending")
      end

      it "reverts the processed_by" do
        expect { subject } .to change { Procedure.find(procedure.id).processed_by } .to(nil)
      end

      it "reverts processing date" do
        expect { subject } .to change { Procedure.find(procedure.id).processed_at } .to(nil)
      end

      it "reverts comment" do
        expect { subject } .to change { Procedure.find(procedure.id).comment } .to(nil)
      end

      context "with dependent procedures" do
        let(:procedure) { create(:document_verification, :with_dependent_procedure, :undoable) }
        let(:dependent_procedure) { procedure.dependent_procedures.first }

        it "reverts procedure state" do
          expect { subject } .to change { Procedure.find(dependent_procedure.id).state } .to("pending")
        end

        it "reverts processed_by" do
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

    context "when undoing a rejected procedure" do
      let(:procedure) { create(:document_verification, :undoable_rejected) }

      it "broadcasts :ok" do
        expect { subject } .to broadcast(:ok)
      end

      it "reverts procedure state" do
        expect { subject } .to change { Procedure.find(procedure.id).state } .to("pending")
      end

      it "reverts the processed_by" do
        expect { subject } .to change { Procedure.find(procedure.id).processed_by } .to(nil)
      end

      it "reverts processing date" do
        expect { subject } .to change { Procedure.find(procedure.id).processed_at } .to(nil)
      end

      it "reverts comment" do
        expect { subject } .to change { Procedure.find(procedure.id).comment } .to(nil)
      end

      context "with dependent procedures" do
        let(:procedure) { create(:document_verification, :with_dependent_procedure, :undoable_rejected) }
        let(:dependent_procedure) { procedure.dependent_procedures.first }

        it "reverts procedure state" do
          expect { subject } .to change { Procedure.find(dependent_procedure.id).state } .to("pending")
        end

        it "reverts processed_by" do
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

    context "when processor is other" do
      let(:admin) { create(:admin) }

      it "broadcasts :invalid" do
        expect { subject } .to broadcast(:invalid)
      end

      it "does not revert procedure state" do
        expect { subject } .not_to change { Procedure.find(procedure.id).state }
      end

      it "does not revert processed_by" do
        expect { subject } .not_to change { Procedure.find(procedure.id).processed_by }
      end

      it "does not revert processing date" do
        expect { subject } .not_to change { Procedure.find(procedure.id).processed_at }
      end

      it "does not revert comment" do
        expect { subject } .not_to change { Procedure.find(procedure.id).comment }
      end

      context "with dependent procedures" do
        let(:procedure) { create(:document_verification, :with_dependent_procedure, :undoable) }
        let(:dependent_procedure) { procedure.dependent_procedures.first }

        it "does not revert procedure state" do
          expect { subject } .not_to change { Procedure.find(dependent_procedure.id).state }
        end

        it "does not revert processed_by" do
          expect { subject } .not_to change { Procedure.find(dependent_procedure.id).processed_by }
        end

        it "does not revert processing date" do
          expect { subject } .not_to change { Procedure.find(dependent_procedure.id).processed_at }
        end

        it "does not revert comment" do
          expect { subject } .not_to change { Procedure.find(dependent_procedure.id).comment }
        end
      end
    end

    context "when processor is the affected person" do
      let(:admin) { build(:admin, person: procedure.person) }

      it "broadcasts :invalid" do
        expect { subject }.to broadcast(:invalid)
      end
    end
  end
end
