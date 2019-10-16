# frozen_string_literal: true

require "rails_helper"

describe ProceduresChannel, type: :channel do
  include_context "with a logged user for the channel"

  let(:procedure) { create(:document_verification) }
  let(:procedure_id) { procedure.id }
  let(:lock_version) { procedure.lock_version }

  it "successfully subscribes" do
    subscribe procedure_id: procedure_id, lock_version: lock_version
    expect(subscription).to be_confirmed
  end
end
