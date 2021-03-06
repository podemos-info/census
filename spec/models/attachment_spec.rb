# frozen_string_literal: true

require "rails_helper"

describe Attachment, :db do
  subject { attachment }

  let(:attachment) { build(:attachment) }

  matcher :be_a_png do
    match do |uploader|
      uploader.read[0..3] == "\x89PNG".b
    end
  end

  matcher :be_encrypted do
    match do |uploader|
      File.open(file_path(uploader)).read[0..3] == "@EnC".b
    end
  end

  it { is_expected.to be_valid }

  context "when saved" do
    let(:attachment) { create(:attachment) }

    it "encrypts original file" do
      expect(attachment.file).to be_encrypted
    end

    it "encrypts versions" do
      expect(attachment.file.thumbnail).to be_encrypted
    end
  end

  context "when attachment file versions should be recoverable" do
    subject(:file) { attachment.file }

    before do
      attachment.save!
      FileUtils.rm_rf(File.join(attachment.file.root.to_s, attachment.file.cache_dir)) # delete all cache files
      attachment.reload
    end

    it { is_expected.to be_encrypted }
    it { is_expected.to be_a_png }

    context "with versions file" do
      subject(:thumbnail) { file.thumbnail }

      it { is_expected.to be_encrypted }
      it { is_expected.to be_a_png }
    end

    it "keeps file versions encrypted" do
      expect(file.thumbnail).to be_encrypted
    end

    describe "#recreate_versions!" do
      subject { file.recreate_versions! }

      before { File.delete(version_path) }

      let(:version_path) { file_path(file.thumbnail) }

      it { expect { subject } .to change { File.exist?(version_path) } }

      context "with versions file" do
        subject(:thumbnail) { file.thumbnail }

        before { file.recreate_versions! }

        it { is_expected.to be_encrypted }
        it { is_expected.to be_a_png }
      end
    end
  end

  def file_path(uploader)
    root_version = uploader.version_name.present? ? uploader.parent_version : uploader
    File.join(uploader.root.to_s, uploader.store_path(root_version.file.filename))
  end
end
