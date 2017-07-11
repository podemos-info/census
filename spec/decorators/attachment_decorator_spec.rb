# frozen_string_literal: true

require "rails_helper"

describe AttachmentDecorator do
  let(:attachment) { build(:attachment) }
  subject { AttachmentDecorator.new(attachment) }
end
