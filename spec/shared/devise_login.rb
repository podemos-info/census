# frozen_string_literal: true

shared_context "with a devise login", shared_context: :metadata do
  before do
    sign_in current_admin
  end

  let(:current_admin) { create(:admin) }
end
