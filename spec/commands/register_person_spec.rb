# frozen_string_literal: true

require "rails_helper"

describe RegisterPerson do
  let(:person) { build(:person) }
  let(:level) { person.level }
  let(:files) do
    attachment = build(:attachment)
    2.times.map do
      ActionDispatch::Http::UploadedFile.new(filename: attachment.file.filename, type: attachment.content_type, tempfile: attachment.file.file)
    end
  end

  let(:form) do
    instance_double(
      PersonForm,
      invalid?: !valid,
      valid?: valid,
      first_name: person.first_name,
      last_name1: person.last_name1,
      last_name2: person.last_name2,
      document_type: person.document_type,
      document_id: person.document_id,
      document_scope: person.document_scope,
      born_at: person.born_at,
      gender: person.gender,
      address: person.address,
      address_scope: person.address_scope,
      postal_code: person.postal_code,
      scope: person.scope,
      email: person.email,
      phone: person.phone,
      extra: person.extra,
      level: level,
      files: files
    )
  end

  subject do
    RegisterPerson.call(form)
  end

  describe "when valid" do
    let(:valid) { true }

    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "register the person" do
      expect { subject } .to change { Person.count }.by(1)
    end

    it "create a verification procedure" do
      expect { subject } .to change { Procedure.count }.by(1)
    end

    context "change membership level" do
      let(:level) { "member" }

      it "create a verification procedure and a change of membership level procedure" do
        expect { subject } .to change { Procedure.count }.by(2)
      end
    end
  end

  describe "when invalid" do
    let(:valid) { false }

    it "doesn't register the person" do
      expect { subject } .to change { Person.count }.by(0)
    end
  end
end
