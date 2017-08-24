# frozen_string_literal: true

require "rails_helper"

describe AttachmentDecorator do
  let(:attachment) { build(:attachment) }
  subject do
    attachment.decorate
  end

  context "view_path" do
    let(:attachment) { create(:attachment) }
    it "returns the original file path" do
      expect(subject.view_path).to eq("/procedures/#{attachment.procedure.id}/view_attachment?attachment_id=#{attachment.id}")
    end
  end
end
