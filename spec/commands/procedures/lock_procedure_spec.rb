# frozen_string_literal: true

require "rails_helper"

describe Procedures::LockProcedure do
  with_versioning do
    subject(:lock_procedure) { described_class.call(form: form, admin: admin) }

    let(:procedure) { create(:document_verification) }
    let(:admin) { create(:admin) }
    let(:form_class) { Procedures::LockProcedureForm }
    let(:valid) { true }
    let(:force) { false }

    let(:form) do
      instance_double(
        form_class,
        invalid?: !valid,
        valid?: valid,
        force?: force,
        procedure: procedure,
        lock_version: procedure.lock_version
      )
    end

    shared_examples "it locks the procedure" do
      it { expect { subject } .to broadcast(:ok) }

      it "changes the processing_by attribute" do
        expect { subject } .to change { Procedure.find(procedure.id).processing_by } .to(admin)
      end

      it "changes the processing_at attribute" do
        expect { subject } .to change { Procedure.find(procedure.id).processing_at }
      end

      it "doesn't change the updated_at attribute" do
        expect { subject } .not_to change { Procedure.find(procedure.id).updated_at }
      end
    end

    shared_examples "it doesn't lock the procedure" do
      it "doesn't change the processing_by attribute" do
        expect { subject } .not_to change { Procedure.find(procedure.id).processing_by }
      end

      it "doesn't change the processing_at attribute" do
        expect { subject } .not_to change { Procedure.find(procedure.id).processing_at }
      end
    end

    it_behaves_like "it locks the procedure"

    context "when form is invalid" do
      let(:valid) { false }

      it { expect { subject } .to broadcast(:invalid) }

      it_behaves_like "it doesn't lock the procedure"
    end

    context "when an admin is processing the procedure" do
      let(:procedure) { create(:document_verification, processing_by: processing_by) }
      let(:processing_by) { create(:admin) }

      it { expect { subject } .to broadcast(:busy) }

      it_behaves_like "it doesn't lock the procedure"

      context "when is the same admin" do
        let(:processing_by) { admin }

        it { expect { subject } .to broadcast(:noop) }

        it_behaves_like "it doesn't lock the procedure"
      end

      context "when forcing the lock" do
        let(:force) { true }

        it_behaves_like "it locks the procedure"
      end
    end

    context "when procedure has changed while processing" do
      before do
        procedure
        Procedure.find(procedure.id).touch
      end

      it { expect { subject } .to broadcast(:conflict) }

      it_behaves_like "it doesn't lock the procedure"
    end
  end
end
