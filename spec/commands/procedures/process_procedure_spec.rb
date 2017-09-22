# frozen_string_literal: true

require "rails_helper"

describe Procedures::ProcessProcedure do
  subject(:process_procedure) { described_class.call(procedure, processed_by, params) }

  let!(:procedure) { create(:verification_document) }
  let(:event) { :accept }
  let(:params) { { event: event, comment: "This is a comment" } }
  let!(:processed_by) { create(:admin) }

  describe "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "updates procedure state" do
      expect { subject } .to change { Procedure.find(procedure.id).state } .from("pending").to("accepted")
    end

    it "sets processed_by" do
      expect { subject } .to change { Procedure.find(procedure.id).processed_by } .to(processed_by)
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

      it "sets processed_by" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).processed_by } .to(processed_by)
      end

      it "sets processing date" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).processed_at }
      end

      it "updates comment" do
        expect { subject } .to change { Procedure.find(dependent_procedure.id).comment } .to("This is a comment")
      end
    end
  end

  context "when processed_by" do
    context "is null" do
      let(:processed_by) { nil }

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
        let(:processed_by) { nil }
        let(:procedure) { create(:verification_document, :with_dependent_procedure) }
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

    context "is the affected person" do
      let(:processed_by) { build(:admin, person: procedure.person) }
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
