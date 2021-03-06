# frozen_string_literal: true

require "rails_helper"

PERSONAL_DATA_FIELDS = %w(first_name last_name1 last_name2 document_type document_id document_scope.code born_at
                          gender address postal_code address_scope.code email phone membership_allowed?
                          created_at).freeze
INTERNAL_DATA_FIELDS = %w(updated_at discarded_at scope_id address_scope_id document_scope_id).freeze
STATE_FIELDS = %w(scope.code state verification membership_level).freeze

describe Api::V1::PeopleController, type: :controller do
  let(:scope) { create(:scope) }
  let(:address_scope) { create(:scope) }
  let(:scope_code) { scope.code }
  let(:address_scope_code) { address_scope.code }

  with_versioning do
    describe "create method" do
      subject(:endpoint) { post :create, params: params }

      let(:person) { build(:person) }
      let(:document_scope) { person.document_scope }
      let(:document_scope_code) { document_scope.code }

      let(:params) do
        params = { person: person.attributes.deep_symbolize_keys }
        params[:person][:origin_qualified_id] = person.qualified_id_at("participa2-1")
        params[:person][:scope_code] = scope_code
        params[:person][:address_scope_code] = address_scope_code
        params[:person][:document_scope_code] = document_scope_code
        params
      end

      it { is_expected.to have_http_status(:accepted) }
      it { expect(subject.content_type).to eq("application/json") }

      include_examples "doesn't track the user visit"

      it_behaves_like "an API endpoint that forbids modifications on slave mode"

      it "creates a new person" do
        expect { subject } .to change(Person, :count).by(1)
      end

      it "returns the create person id" do
        expect(subject.body).to eq({ person_id: Person.last.id } .to_json)
      end

      it "creates a new registration procedure" do
        expect { subject } .to change(Procedures::Registration, :count).by(1)
      end

      describe "procedure created" do
        subject(:created_procedure) { Procedures::Registration.last }

        before { endpoint }

        it "correctly sets the user scope" do
          expect(created_procedure.scope_id).to eq(scope.id)
        end

        it "correctly sets the user address_scope" do
          expect(created_procedure.address_scope_id).to eq(address_scope.id)
        end

        it "correctly sets the user document_scope" do
          expect(created_procedure.document_scope_id).to eq(document_scope.id)
        end
      end

      context "with an invalid scope id" do
        let(:scope_code) { "AN INVALID SCOPE CODE" }

        it { expect(subject).to have_http_status(:unprocessable_entity) }
        it { expect(subject.content_type).to eq("application/json") }

        it "returns the errors collection" do
          expect(subject.body).to eq({ scope: [{ error: "blank" }] }.to_json)
        end
      end

      context "when saving fails" do
        before { stub_command("People::CreateRegistration", :error) }

        it { expect(subject).to have_http_status(:internal_server_error) }
        it { expect(subject.content_type).to eq("application/json") }
      end
    end

    describe "update method" do
      subject(:endpoint) { patch :update, params: { id: person.qualified_id_at("participa2-1"), **changes } }

      let(:person) { create(:person) }
      let(:changes) { { person: { first_name: "CHANGED", scope_code: scope_code } } }
      let(:scope_code) { scope.code }

      it { is_expected.to have_http_status(:accepted) }
      it { expect(subject.content_type).to eq("application/json") }

      include_examples "doesn't track the user visit"

      it_behaves_like "an API endpoint that forbids modifications on slave mode"

      it "creates a new person data change procedure" do
        expect { subject } .to change(Procedures::PersonDataChange, :count).by(1)
      end

      describe "procedure created" do
        subject(:created_procedure) { Procedures::PersonDataChange.last }

        before { endpoint }

        it "correctly saves the affected person" do
          expect(subject.person_id).to eq(person.id)
        end

        it "correctly saves the name" do
          expect(subject.first_name).to eq("CHANGED")
        end

        it "correctly saves the scope" do
          expect(subject.scope_id).to eq(scope.id)
        end
      end

      context "with an invalid scope id" do
        let(:scope_code) { "AN INVALID SCOPE CODE" }

        it { expect(subject).to have_http_status(:unprocessable_entity) }
        it { expect(subject.content_type).to eq("application/json") }

        it "returns the errors collection" do
          expect(subject.body).to eq({ scope: [{ error: "blank" }] }.to_json)
        end
      end

      context "when saving fails" do
        before { stub_command("People::CreatePersonDataChange", :error) }

        it { expect(subject).to have_http_status(:internal_server_error) }
        it { expect(subject.content_type).to eq("application/json") }
      end
    end

    describe "destroy method" do
      subject(:endpoint) { patch :destroy, params: { id: person_id, **params } }

      let(:person) { create(:person) }
      let(:person_id) { person.qualified_id_at("participa2-1") }
      let(:params) { { reason: "I don't wanna", channel: "decidim" } }

      it { is_expected.to have_http_status(:accepted) }
      it { expect(subject.content_type).to eq("application/json") }

      include_examples "doesn't track the user visit"

      it_behaves_like "an API endpoint that forbids modifications on slave mode"

      it "creates a new cancellation procedure" do
        expect { subject } .to change(Procedures::Cancellation, :count).by(1)
      end

      describe "procedure created" do
        subject(:created_procedure) { Procedures::Cancellation.last }

        before { endpoint }

        it "correctly saves the affected person" do
          expect(subject.person_id).to eq(person.id)
        end

        it "correctly save the given reason" do
          expect(subject.reason).to eq("I don't wanna")
        end

        it "correctly save the given channel" do
          expect(subject.channel).to eq("decidim")
        end
      end

      context "with an invalid person id" do
        let(:person_id) { 0 }

        it { expect(subject).to have_http_status(:unprocessable_entity) }
        it { expect(subject.content_type).to eq("application/json") }

        it "returns the errors collection" do
          expect(subject.body).to eq({ person: [{ error: "blank" }] }.to_json)
        end
      end

      context "when saving fails" do
        before { stub_command("People::CreateCancellation", :error) }

        it { expect(subject).to have_http_status(:internal_server_error) }
        it { expect(subject.content_type).to eq("application/json") }
      end
    end
  end

  with_versioning do
    describe "retrieve person information" do
      subject(:endpoint) { get :show, params: params }

      let(:person) { create(:person) }
      let(:params) { { id: person.qualified_id_at("participa2-1") } }

      it { is_expected.to be_successful }

      include_examples "doesn't track the user visit"

      context "when using the document_id to identify the user" do
        let(:params) { { id: person.qualified_id_by_document_id } }

        it { is_expected.to be_successful }
      end

      describe "returned data" do
        subject(:response) { JSON.parse(endpoint.body) }

        matcher :match_field do |person, field|
          match do |model|
            person_field = field.split(".").reduce(person, &:send)
            person_field = person_field.as_json if person_field.is_a?(Date) || person_field.is_a?(Time)
            model[field.gsub(".", "_")] == person_field
          end
        end

        shared_examples_for "returns full state information" do
          STATE_FIELDS.each do |field|
            it "includes person #{field.humanize.downcase}" do
              expect(subject).to match_field(person, field)
            end
          end
        end

        shared_examples_for "returns person personal data" do
          PERSONAL_DATA_FIELDS.each do |field|
            it "includes person #{field.humanize.downcase}" do
              expect(subject).to match_field(person, field)
            end
          end
        end

        shared_examples_for "returns person scopes information" do
          it "includes information for all person scopes" do
            expect(subject["scopes"].map { |scope| scope["id"] }).to match_array((
              person.scope.part_of +
              person.address_scope.part_of +
              person.document_scope.part_of
            ).uniq)
          end

          it "includes the same information for every scope" do
            subject["scopes"].each do |scope|
              expect(scope.keys).to match_array(%w(id name scope_type code mappings))
            end
          end
        end

        shared_examples_for "does not return internal information" do
          it "does not include internal fields" do
            expect(subject.keys).not_to include(INTERNAL_DATA_FIELDS)
          end
        end

        shared_examples_for "does not return person personal data" do
          it "does not include person data fields" do
            expect(subject.keys).not_to include(PERSONAL_DATA_FIELDS)
          end
        end

        shared_examples_for "does not return person scopes information" do
          it "does not include scope field" do
            expect(subject.keys).not_to include(%(scopes))
          end
        end

        include_examples "returns full state information"

        include_examples "returns person personal data"

        include_examples "does not return person scopes information"

        include_examples "does not return internal information"

        context "when using census qualified id" do
          let(:params) { { id: person.qualified_id } }

          include_examples "returns full state information"

          include_examples "returns person personal data"

          include_examples "does not return person scopes information"

          include_examples "does not return internal information"
        end

        context "when scopes information is requested" do
          let(:params) { { id: person.qualified_id_at("participa2-1"), excludes: [""] } }

          include_examples "returns full state information"

          include_examples "returns person personal data"

          include_examples "returns person scopes information"

          include_examples "does not return internal information"
        end

        context "when only email information is requested" do
          let(:params) { { id: person.qualified_id_at("participa2-1"), includes: %w(email) } }

          it "only includes the email field" do
            expect(subject).to eq "email" => person.email
          end
        end

        context "when user is discarded" do
          before do
            person.discard
          end

          include_examples "returns full state information"

          include_examples "does not return person personal data"

          include_examples "does not return person scopes information"

          include_examples "does not return internal information"
        end

        context "when retrieving an old person version" do
          before do
            current_person.save
            Timecop.travel 1.month.from_now
            current_person.verify!
          end

          after { Timecop.return }

          let(:params) { { id: current_person.qualified_id_at("participa2-1"), version_at: version_at } }
          let(:current_person) { create(:person) }
          let(:person) { current_person.paper_trail.version_at(version_at) }
          let(:version_at) { 7.days.ago }

          include_examples "returns full state information"

          include_examples "returns person personal data"

          include_examples "does not return person scopes information"

          include_examples "does not return internal information"

          it "is not verified" do
            expect(subject["verification"]).to eq("not_verified")
          end

          context "when user is discarded" do
            before do
              Timecop.travel 1.month.from_now
              current_person.discard
            end

            after { Timecop.return }

            include_examples "returns full state information"

            include_examples "does not return person personal data"

            include_examples "does not return person scopes information"

            include_examples "does not return internal information"
          end
        end
      end
    end
  end
end
