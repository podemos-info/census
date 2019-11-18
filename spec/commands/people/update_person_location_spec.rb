# frozen_string_literal: true

require "rails_helper"

describe People::UpdatePersonLocation do
  subject(:command) { described_class.call(form: form) }

  let(:person) { create(:person) }
  let(:form_class) { People::PersonLocationForm }
  let(:valid) { true }

  let(:form) do
    instance_double(
      form_class,
      invalid?: !valid,
      valid?: valid,
      person: person,
      ip: ip,
      user_agent: user_agent,
      time: time
    )
  end

  let(:ip) { Faker::Internet.ip_v4_address }
  let(:user_agent) { Faker::Internet.user_agent }
  let(:time) { 1.minute.ago }

  it "broadcasts :ok" do
    expect { subject } .to broadcast(:ok)
  end

  it "creates a new person location" do
    expect { subject } .to change(PersonLocation, :count).by(1)
  end

  it "stores the location ip" do
    subject
    expect(PersonLocation.last.ip).to eq(ip)
  end

  it "stores the location user agent" do
    subject
    expect(PersonLocation.last.user_agent).to eq(user_agent)
  end

  it "stores the location time as creation time" do
    subject
    expect(PersonLocation.last.created_at).to be_within(1.second).of(time)
  end

  it "stores the location time as update time" do
    subject
    expect(PersonLocation.last.updated_at).to be_within(1.second).of(time)
  end

  it "doesn't set the discarded time" do
    subject
    expect(PersonLocation.last.discarded_at).to be_nil
  end

  context "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't create the new person location" do
      expect { subject } .not_to change(PersonLocation, :count)
    end
  end

  context "when the same location already exists" do
    before { person_location }

    let(:person_location) do
      create(:person_location,
             person: person,
             ip: ip,
             user_agent: user_agent,
             created_at: created_at,
             updated_at: updated_at)
    end
    let(:created_at) { 1.minute.before(time) }
    let(:updated_at) { created_at }

    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it { expect { subject } .not_to change { person_location.reload.ip } }
    it { expect { subject } .not_to change { person_location.reload.user_agent } }
    it { expect { subject } .not_to change { person_location.reload.created_at } }
    it { expect { subject } .not_to change { person_location.reload.discarded_at }.from(nil) }

    it "updates the existing update time" do
      expect { subject } .to change { person_location.reload.updated_at.round }
        .from(updated_at.round).to(time.round)
    end

    context "when existing location was updated after this one" do
      let(:updated_at) { 1.minute.after(time) }

      it "broadcasts :ok" do
        expect { subject } .to broadcast(:ok)
      end

      it "doesn't change existing location" do
        expect { subject } .not_to change(PersonLocation, :last)
      end
    end

    context "when existing location is newer that this one" do
      let(:created_at) { 1.minute.after(time) }

      it "broadcasts :ok" do
        expect { subject } .to broadcast(:ok)
      end

      it "doesn't update the existing ip" do
        expect { subject } .not_to change { PersonLocation.last.ip }
      end

      it "doesn't update the existing user agent" do
        expect { subject } .not_to change { PersonLocation.last.user_agent }
      end

      it "updates the existing creation time" do
        expect { subject } .to change { PersonLocation.last.created_at.round }
          .from(created_at.round).to(time.round)
      end

      it "doesn't update the existing update time" do
        expect { subject } .not_to change { PersonLocation.last.updated_at }
      end
    end
  end

  context "when a different location already exists" do
    before { person_location }

    let(:person_location) do
      create(:person_location,
             person: person,
             ip: ip2,
             user_agent: user_agent2,
             created_at: created_at,
             updated_at: updated_at)
    end

    let(:ip2) { Faker::Internet.ip_v4_address }
    let(:user_agent2) { Faker::Internet.user_agent }
    let(:created_at) { 1.minute.before(time) }
    let(:updated_at) { created_at }

    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it { expect { subject } .not_to change { person_location.reload.ip } }
    it { expect { subject } .not_to change { person_location.reload.user_agent } }
    it { expect { subject } .not_to change { person_location.reload.created_at } }
    it { expect { subject } .not_to change { person_location.reload.updated_at } }

    it "sets the existing discarded time" do
      expect { subject } .to change { person_location.reload.discarded_at&.round }
        .from(nil).to(time.round)
    end

    it "creates a new person location" do
      expect { subject } .to change(PersonLocation, :count).by(1)
    end

    it "stores the location ip" do
      subject
      expect(PersonLocation.last.ip).to eq(ip)
    end

    it "stores the location user agent" do
      subject
      expect(PersonLocation.last.user_agent).to eq(user_agent)
    end

    it "stores the location time as creation time" do
      subject
      expect(PersonLocation.last.created_at).to be_within(1.second).of(time)
    end

    it "stores the location time as update time" do
      subject
      expect(PersonLocation.last.updated_at).to be_within(1.second).of(time)
    end

    it "doesn't set the discarded time" do
      subject
      expect(PersonLocation.last.discarded_at).to be_nil
    end

    context "when existing location was updated after this one" do
      # this scenario is very rare, and its called transient location:
      #  when a location for a person is registered inside an existing
      #  and different location, it is saved as an instantaneous location,
      #  with the same time for creation and deletion, that overlaps with
      #  the existing location.
      let(:updated_at) { 1.minute.after(time) }

      it "broadcasts :ok" do
        expect { subject } .to broadcast(:ok)
      end

      it "doesn't change existing location" do
        expect { subject } .not_to change { person_location }
      end

      it "stores the location ip" do
        subject
        expect(PersonLocation.last.ip).to eq(ip)
      end

      it "stores the location user agent" do
        subject
        expect(PersonLocation.last.user_agent).to eq(user_agent)
      end

      it "stores the location time as creation time" do
        subject
        expect(PersonLocation.last.created_at).to be_within(1.second).of(time)
      end

      it "stores the location time as update time" do
        subject
        expect(PersonLocation.last.updated_at).to be_within(1.second).of(time)
      end

      it "stores the location time as discarded time" do
        subject
        expect(PersonLocation.last.discarded_at).to be_within(1.second).of(time)
      end
    end

    context "when existing location is newer that this one" do
      let(:created_at) { 1.minute.after(time) }

      it "broadcasts :ok" do
        expect { subject } .to broadcast(:ok)
      end

      it "doesn't change the existing location" do
        expect { subject } .not_to change { person_location }
      end

      it "creates a new person location" do
        expect { subject } .to change(PersonLocation, :count).by(1)
      end

      it "stores the location ip" do
        subject
        expect(PersonLocation.last.ip).to eq(ip)
      end

      it "stores the location user agent" do
        subject
        expect(PersonLocation.last.user_agent).to eq(user_agent)
      end

      it "stores the location time as creation time" do
        subject
        expect(PersonLocation.last.created_at).to be_within(1.second).of(time)
      end

      it "stores the location time as update time" do
        subject
        expect(PersonLocation.last.updated_at).to be_within(1.second).of(time)
      end

      it "stores the existing location creation time as discard time" do
        subject
        expect(PersonLocation.last.discarded_at).to be_within(1.second).of(person_location.created_at)
      end
    end
  end
end
