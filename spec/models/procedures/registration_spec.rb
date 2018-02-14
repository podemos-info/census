# frozen_string_literal: true

require "rails_helper"

describe Procedures::Registration, :db do
  subject(:procedure) { create(:registration, :ready_to_process, person_copy_data: person) }
  let(:person) { build(:person) }

  it { is_expected.to be_valid }

  it "#acceptable? returns true" do
    is_expected.to be_acceptable
  end

  context "when accepted" do
    [:document_type, :document_id, :document_scope_id, :phone, :email, :address, :address_scope_id,
     :postal_code, :scope_id, :gender, :born_at].each do |attribute|
      it "sets #{attribute}" do
        expect { procedure.accept! } .to change { procedure.person.send(attribute) } .from(nil).to(person.send(attribute))
      end
    end

    it "changes the person membership level to follower" do
      expect { procedure.accept! } .to change { procedure.person.membership_level } .from("pending").to("follower")
    end
  end

  context "when rejected" do
    [:document_type, :document_id, :document_scope_id, :phone, :email, :address, :address_scope_id,
     :postal_code, :scope_id, :gender, :born_at].each do |attribute|
      it "sets #{attribute}" do
        expect { procedure.reject! } .not_to change { procedure.person.send(attribute) }
      end
    end

    it "changes the person membership level to rejected" do
      expect { procedure.reject! } .to change { procedure.person.membership_level } .from("pending").to("rejected")
    end
  end

  with_versioning do
    context "after accepting the procedure" do
      subject(:undo) { procedure.undo! }
      before { procedure.accept! }

      [:document_type, :document_id, :document_scope_id, :phone, :email, :address, :address_scope_id,
       :postal_code, :scope_id, :gender, :born_at].each do |attribute|
        it "undoes unsets #{attribute}" do
          expect { subject } .to change { procedure.person.send(attribute) } .from(person.send(attribute)).to(nil)
        end
      end

      it "undoes change of person membership level" do
        expect { subject } .to change { procedure.person.membership_level } .from("follower").to("pending")
      end
    end

    context "after rejecting the procedure" do
      subject(:undo) { procedure.undo! }
      before { procedure.reject! }

      it "undoes change of person membership level" do
        expect { subject } .to change { procedure.person.membership_level } .from("rejected").to("pending")
      end
    end
  end
end
