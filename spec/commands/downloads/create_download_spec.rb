# frozen_string_literal: true

require "rails_helper"

describe Downloads::CreateDownload do
  subject(:command) { described_class.call(form: form, admin: admin) }
  let(:download) { build(:download) }
  let(:admin) { create(:admin) }
  let(:valid) { true }
  let(:file) do
    ActionDispatch::Http::UploadedFile.new(filename: download.file.filename, type: download.content_type, tempfile: download.file.file)
  end

  let(:form) do
    instance_double(
      DownloadForm,
      invalid?: !valid,
      valid?: valid,
      person: download.person,
      file: file,
      expires_at: download.expires_at
    )
  end

  context "when valid" do
    it "broadcasts :ok" do
      expect { subject } .to broadcast(:ok)
    end

    it "creates the download" do
      expect { subject } .to change { Download.count } .by(1)
    end

    context "saved download" do
      subject(:saved_download) do
        command
        Download.last
      end
      it "has the given person" do
        expect(subject.person.id) .to eq(form.person.id)
      end
      it "has the given file" do
        expect(subject.file.read) .to eq(form.file.tempfile.read)
      end
      it "has the given expiration date" do
        expect(subject.expires_at) .to eq(form.expires_at)
      end
    end
  end

  context "when invalid" do
    let(:valid) { false }

    it "broadcasts :invalid" do
      expect { subject } .to broadcast(:invalid)
    end

    it "doesn't create the download" do
      expect { subject } .to_not change { Download.count }
    end
  end
end
