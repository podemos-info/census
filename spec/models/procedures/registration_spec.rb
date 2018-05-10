# frozen_string_literal: true

require "rails_helper"

describe Procedures::Registration, :db do
  subject(:procedure) { create(:registration, :ready_to_process, person_copy_data: person) }
  let(:person) { build(:person) }

  it { is_expected.to be_valid }

  it "is acceptable" do
    is_expected.to be_acceptable
  end

  it "is auto_processable" do
    is_expected.to be_auto_processable
  end

  context "when accepted" do
    subject(:accepting) { procedure.accept! }

    [:document_type, :document_id, :document_scope_id, :phone, :email, :address, :address_scope_id,
     :postal_code, :scope_id, :gender, :born_at].each do |attribute|
      it "sets #{attribute}" do
        expect { subject } .to change { procedure.person.send(attribute) } .from(nil).to(person.send(attribute))
      end
    end

    it "sets the person external system identifier" do
      expect { subject } .to change { procedure.person.reload.qualified_id_at(:decidim) } .to(person.qualified_id_at(:decidim))
    end

    it "changes the person membership level to follower" do
      expect { subject } .to change { procedure.person.state } .from("pending").to("enabled")
    end

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) { ["census.people.full_status_changed", { person: procedure.person.qualified_id }] }
    end
  end

  context "when rejected" do
    subject(:accepting) { procedure.reject! }

    [:document_type, :document_id, :document_scope_id, :phone, :email, :address, :address_scope_id,
     :postal_code, :scope_id, :gender, :born_at].each do |attribute|
      it "sets #{attribute}" do
        expect { subject } .not_to change { procedure.person.send(attribute) }
      end
    end

    it "changes the person membership level to rejected" do
      expect { subject } .to change { procedure.person.state } .from("pending").to("trashed")
    end

    it_behaves_like "an event notifiable with hutch" do
      let(:publish_notification) { ["census.people.full_status_changed", { person: procedure.person.qualified_id }] }
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
        expect { subject } .to change { procedure.person.state } .from("enabled").to("pending")
      end
    end

    context "after rejecting the procedure" do
      subject(:undo) { procedure.undo! }
      before { procedure.reject! }

      it "undoes change of person membership level" do
        expect { subject } .to change { procedure.person.state } .from("trashed").to("pending")
      end
    end
  end
end
