# frozen_string_literal: true

require "rails_helper"

describe AttachmentDecorator do
  subject { attachment.decorate(context: { current_admin: admin }) }

  let(:attachment) { build(:attachment) }
  let(:admin) { build(:admin) }

  describe "view_path" do
    let(:attachment) { create(:attachment) }
    it "returns the original file path" do
      expect(subject.view_path).to eq("/procedures/#{attachment.procedure.id}/view_attachment?attachment_id=#{attachment.id}")
    end
  end
end
