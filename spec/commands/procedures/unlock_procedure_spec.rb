# frozen_string_literal: true

require "rails_helper"

describe Procedures::UnlockProcedure do
  with_versioning do
    subject(:unlock_procedure) { described_class.call(form: form, admin: admin) }

    let(:procedure) { create(:document_verification, processing_by: processing_by) }
    let(:processing_by) { admin }
    let(:admin) { create(:admin) }
    let(:form_class) { Procedures::LockProcedureForm }
    let(:valid) { true }

    let(:form) do
      instance_double(
        form_class,
        invalid?: !valid,
        valid?: valid,
        procedure: procedure,
        lock_version: procedure.lock_version
      )
    end

    shared_examples "it unlocks the procedure" do
      it { expect { subject } .to broadcast(:ok) }

      it "changes the processing_by attribute" do
        expect { subject } .to change { Procedure.find(procedure.id).processing_by } .to(nil)
      end

      it "changes the processing_at attribute" do
        expect { subject } .to change { Procedure.find(procedure.id).processing_at } .to(nil)
      end

      it "doesn't change the updated_at attribute" do
        expect { subject } .not_to change { Procedure.find(procedure.id).updated_at }
      end
    end

    shared_examples "it doesn't unlock the procedure" do
      it "doesn't change the processing_by attribute" do
        expect { subject } .not_to change { Procedure.find(procedure.id).processing_by }
      end

      it "doesn't change the processing_at attribute" do
        expect { subject } .not_to change { Procedure.find(procedure.id).processing_at }
      end
    end

    it_behaves_like "it unlocks the procedure"

    context "when form is invalid" do
      let(:valid) { false }

      it { expect { subject } .to broadcast(:invalid) }

      it_behaves_like "it doesn't unlock the procedure"
    end

    context "when a different admin is processing the procedure" do
      let(:processing_by) { create(:admin) }

      it { expect { subject } .to broadcast(:noop) }

      it_behaves_like "it doesn't unlock the procedure"
    end

    context "when nobody is processing the procedure" do
      let(:processing_by) { nil }

      it { expect { subject } .to broadcast(:noop) }

      it_behaves_like "it doesn't unlock the procedure"
    end

    context "when procedure has changed while processing" do
      before do
        procedure
        Procedure.find(procedure.id).touch
      end

      it { expect { subject } .to broadcast(:conflict) }

      it_behaves_like "it doesn't unlock the procedure"
    end
  end
end
