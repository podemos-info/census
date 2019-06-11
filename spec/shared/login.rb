# frozen_string_literal: true

shared_context "with a devise login", shared_context: :metadata do
  before do
    sign_in current_admin
  end

  let(:current_admin) { create(:admin) }
end

shared_context "with a CAS login", shared_context: :metadata do
  around do |test|
    Settings.security.cas_server = "https://example.org"

    test.run

    Settings.security.cas_server = nil
  end

  before do
    session["cas"] = { "user" => current_admin.username }
  end

  let(:current_admin) { create(:admin) }
end
