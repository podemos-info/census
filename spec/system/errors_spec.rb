# frozen_string_literal: true

require "rails_helper"

describe "Errors", type: :system do
  subject { visit target_url }

  before(:example, environment: :production) do
    allow(Rails.application).to receive(:env_config)
      .with(no_args)
      .and_wrap_original do |m, *|
        m.call.merge("action_dispatch.show_exceptions" => true, "action_dispatch.show_detailed_exceptions" => false)
      end
  end

  shared_examples_for "a backend url" do
    it "returns html with a message" do
      subject

      aggregate_failures "testing response" do
        expect(page.response_headers["Content-Type"]).to match(/html/)
        expect(page.body).to eq(error_message)
      end
    end

    include_examples "tracks the user visit"
  end

  shared_examples_for "an API url" do
    it "returns empty json" do
      subject

      aggregate_failures "testing response" do
        expect(page.body).to eq("{}")
        expect(page.response_headers["Content-Type"]).to match(/json/)
      end
    end

    include_examples "doesn't track the user visit"
  end

  context "when visiting a non existing url" do
    shared_context "with a backend url" do
      let(:target_url) { "/hakuna" }
    end

    shared_context "with an API url" do
      let(:target_url) { "/api/hakuna" }
    end

    context "when developing" do
      shared_examples_for "an unexistent development url" do
        it "returns an informative exception" do
          expect { subject }.to raise_error(ActionController::RoutingError, "No route matches [GET] \"#{target_url}\"")
        end
      end

      context "with a backend request" do
        include_context "with a backend url"

        it_behaves_like "an unexistent development url"
      end

      context "with an API request" do
        include_context "with an API url"

        it_behaves_like "an unexistent development url"
      end
    end

    context "when running in production", environment: :production do
      shared_examples_for "an unexistent production url" do
        it "returns not found status" do
          subject

          expect(page).to have_http_status(:not_found)
        end
      end

      context "with a backend request" do
        include_context "with a backend url"

        it_behaves_like "an unexistent production url"

        it_behaves_like "a backend url" do
          let(:error_message) { "404 Not found" }
        end
      end

      context "with an API request" do
        include_context "with an API url"

        it_behaves_like "an unexistent production url"

        it_behaves_like "an API url"
      end
    end
  end

  context "when server crashes" do
    shared_context "with a backend url" do
      let(:target_url) { "/login" }

      before do
        allow_any_instance_of(Devise::SessionsController).to receive(:new, &:hakuna_matata)
      end
    end

    shared_context "with an API url" do
      let(:person) { create(:person) }

      let(:target_url) { "api/v1/people/#{person.id}@census" }

      before do
        allow_any_instance_of(Api::V1::PeopleController).to receive(:show, &:hakuna_matata)
      end
    end

    context "when developing" do
      shared_examples_for "a crashing development url" do
        it "crashes properly" do
          expect { subject }.to raise_error(NoMethodError, /undefined method `hakuna_matata' for/)
        end
      end

      context "with a backend request" do
        include_context "with a backend url"

        it_behaves_like "a crashing development url"
      end

      context "with an API request" do
        include_context "with an API url"

        it_behaves_like "a crashing development url"
      end
    end

    context "when running in production", environment: :production do
      shared_examples_for "a crashing production url" do
        it "crashes properly" do
          subject

          expect(page).to have_http_status(:internal_server_error)
        end
      end

      context "with a backend request" do
        include_context "with a backend url"

        it_behaves_like "a crashing production url"

        it_behaves_like "a backend url" do
          let(:error_message) { "500 Internal Server Error" }
        end
      end

      context "with an API request" do
        include_context "with an API url"

        it_behaves_like "a crashing production url"

        it_behaves_like "an API url"
      end
    end
  end
end
