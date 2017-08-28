# frozen_string_literal: true

require "rails_helper"

describe Attachment, :db do
  let(:attachment) { build(:attachment) }

  subject { attachment }

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

  context "attachment file versions should be recoverable" do
    before do
      attachment.save!
      FileUtils.rm_rf(File.join(attachment.file.root.to_s, attachment.file.cache_dir)) # delete all cache files
      attachment.reload
    end

    it "keeps original file encrypted" do
      expect(attachment.file).to be_encrypted
    end

    it "keeps file versions encrypted" do
      expect(attachment.file).to be_encrypted
    end

    it "can retrieve decrypted file" do
      expect(attachment.file).to be_a_png
    end

    it "can recreate versiones" do
      version_path = file_path(attachment.file.thumbnail)
      File.delete(version_path)
      expect(File.exist?(version_path)).to be_falsey

      attachment.file.recreate_versions!
      expect(File.exist?(version_path)).to be_truthy

      expect(attachment.file.thumbnail).to be_a_png
    end
  end

  def file_path(uploader)
    root_version = uploader.version_name.present? ? uploader.parent_version : uploader
    File.join(uploader.root.to_s, uploader.store_path(root_version.file.filename))
  end
end
