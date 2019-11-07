# frozen_string_literal: true

require "rails_helper"

describe DashboardController, type: :controller do
  render_views

  describe "index page" do
    subject { get :index }

    context "with devise authentication" do
      include_context "with a devise login"

      it { is_expected.to be_successful }
      it { is_expected.to render_template("index") }

      include_examples "tracks the user visit"
    end

    context "with CAS authentication" do
      include_context "with a CAS login"

      it { is_expected.to be_successful }
      it { is_expected.to render_template("index") }

      include_examples "tracks the user visit"
    end

    context "when slave mode" do
      include_context "when slave mode"
      include_context "with a devise login"

      it "warns that the system is in read-only mode" do
        expect { subject } .to change { flash[:alert] }
          .from(nil).to("Atención: el sistema está en modo de solo lectura y no permite modificaciones.")
      end
    end
  end

  shared_examples_for "a stats JSON data endpoint" do
    it { expect(subject.content_type).to eq("application/json") }
    it { expect(JSON.parse(subject.body).sort_by { |hash| hash["name"] }).to eq(expected_response.sort_by { |hash| hash["name"] }) }
  end

  describe "people_stats page" do
    subject { get(:people_stats, params: { format: :json, interval: interval }) }

    around do |example|
      Timecop.freeze(freeze_date) do
        admin_person
        people
        example.run
      end
    end

    let(:freeze_date) { DateTime.civil(2019, 6, 15, 12, 30, 0) }
    let(:admin_person) { create(:person, created_at: 2.years.ago) }
    let(:interval) { "" }
    let(:people) do
      [10.months, 3.weeks, 5.days, 6.hours].each do |time|
        Timecop.freeze(time.ago) do
          create(:person, created_at: 1.minute.ago)
          create(:person, :pending, created_at: 10.minutes.ago)
          create(:person, :member, created_at: 15.minutes.ago)
          create(:person, :cancelled, created_at: 30.minutes.ago)
          create(:person, :trashed, created_at: 45.minutes.ago)
        end
      end
    end

    include_context "with a devise login" do
      let(:current_admin) { create(:admin, :data, person: admin_person) }
    end

    it_behaves_like "a stats JSON data endpoint" do
      let(:expected_response) do
        [
          { "name" => "Pendiente",
            "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
            "color" => "orange" },
          { "name" => "Habilitada",
            "data" => { "2019-06-10" => 2, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 2 },
            "color" => "green" },
          { "name" => "Afiliada",
            "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
            "color" => "#683064" },
          { "name" => "Baja",
            "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
            "color" => "red" },
          { "name" => "Borrada",
            "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
            "color" => "gray" }
        ]
      end
    end

    context "when interval is day" do
      let(:interval) { "day" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "name" => "Pendiente", "data" => { "2019-06-15 06:00:00 UTC" => 1 }, "color" => "orange" },
            { "name" => "Habilitada", "data" => { "2019-06-15 06:00:00 UTC" => 2 }, "color" => "green" },
            { "name" => "Afiliada", "data" => { "2019-06-15 06:00:00 UTC" => 1 }, "color" => "#683064" },
            { "name" => "Baja", "data" => { "2019-06-15 00:00:00 UTC" => 1 }, "color" => "red" },
            { "name" => "Borrada", "data" => { "2019-06-15 00:00:00 UTC" => 1 }, "color" => "gray" }
          ]
        end
      end
    end

    context "when interval is week" do
      let(:interval) { "week" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "name" => "Pendiente",
              "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
              "color" => "orange" },
            { "name" => "Habilitada",
              "data" => { "2019-06-10" => 2, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 2 },
              "color" => "green" },
            { "name" => "Afiliada",
              "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
              "color" => "#683064" },
            { "name" => "Baja",
              "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
              "color" => "red" },
            { "name" => "Borrada",
              "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
              "color" => "gray" }
          ]
        end
      end
    end

    context "when interval is month" do
      let(:interval) { "month" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "name" => "Pendiente", "data" => { "2019-05-19" => 1, "2019-05-26" => 0, "2019-06-02" => 0, "2019-06-09" => 2 }, "color" => "orange" },
            { "name" => "Habilitada", "data" => { "2019-05-19" => 2, "2019-05-26" => 0, "2019-06-02" => 0, "2019-06-09" => 4 }, "color" => "green" },
            { "name" => "Afiliada", "data" => { "2019-05-19" => 1, "2019-05-26" => 0, "2019-06-02" => 0, "2019-06-09" => 2 }, "color" => "#683064" },
            { "name" => "Baja", "data" => { "2019-05-19" => 1, "2019-05-26" => 0, "2019-06-02" => 0, "2019-06-09" => 2 }, "color" => "red" },
            { "name" => "Borrada", "data" => { "2019-05-19" => 1, "2019-05-26" => 0, "2019-06-02" => 0, "2019-06-09" => 2 }, "color" => "gray" }
          ]
        end
      end
    end

    context "when interval is year" do
      let(:interval) { "year" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "name" => "Pendiente",
              "data" => { "2018-08-01" => 1, "2018-09-01" => 0, "2018-10-01" => 0, "2018-11-01" => 0, "2018-12-01" => 0, "2019-01-01" => 0,
                          "2019-02-01" => 0, "2019-03-01" => 0, "2019-04-01" => 0, "2019-05-01" => 1, "2019-06-01" => 2 },
              "color" => "orange" },
            { "name" => "Habilitada",
              "data" => { "2018-08-01" => 2, "2018-09-01" => 0, "2018-10-01" => 0, "2018-11-01" => 0, "2018-12-01" => 0, "2019-01-01" => 0,
                          "2019-02-01" => 0, "2019-03-01" => 0, "2019-04-01" => 0, "2019-05-01" => 2, "2019-06-01" => 4 },
              "color" => "green" },
            { "name" => "Afiliada",
              "data" => { "2018-08-01" => 1, "2018-09-01" => 0, "2018-10-01" => 0, "2018-11-01" => 0, "2018-12-01" => 0, "2019-01-01" => 0,
                          "2019-02-01" => 0, "2019-03-01" => 0, "2019-04-01" => 0, "2019-05-01" => 1, "2019-06-01" => 2 },
              "color" => "#683064" },
            { "name" => "Baja",
              "data" => { "2018-08-01" => 1, "2018-09-01" => 0, "2018-10-01" => 0, "2018-11-01" => 0, "2018-12-01" => 0, "2019-01-01" => 0,
                          "2019-02-01" => 0, "2019-03-01" => 0, "2019-04-01" => 0, "2019-05-01" => 1, "2019-06-01" => 2 },
              "color" => "red" },
            { "name" => "Borrada",
              "data" => { "2018-08-01" => 1, "2018-09-01" => 0, "2018-10-01" => 0, "2018-11-01" => 0, "2018-12-01" => 0, "2019-01-01" => 0,
                          "2019-02-01" => 0, "2019-03-01" => 0, "2019-04-01" => 0, "2019-05-01" => 1, "2019-06-01" => 2 },
              "color" => "gray" }
          ]
        end
      end
    end
  end

  describe "procedure_stats page" do
    subject { get(:procedures_stats, params: { format: :json, interval: interval }) }

    around do |example|
      Timecop.freeze(freeze_date) do
        procedures
        example.run
      end
    end

    let(:freeze_date) { DateTime.civil(2019, 6, 15, 12, 30, 0) }
    let(:interval) { "" }
    let(:procedures) do
      [10.months, 3.weeks, 5.days, 6.hours].each do |time|
        Timecop.freeze(time.ago) do
          create(:document_verification, created_at: 1.minute.ago)
          create(:membership_level_change, created_at: 10.minutes.ago)
          create(:registration, created_at: 15.minutes.ago)
          create(:person_data_change, created_at: 30.minutes.ago)
          create(:phone_verification, created_at: 45.minutes.ago)
        end
      end
    end

    include_context "with a devise login" do
      let(:current_admin) { create(:admin, :data) }
    end

    it_behaves_like "a stats JSON data endpoint" do
      let(:expected_response) do
        [
          { "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
            "name" => "Cambio de nivel de membresía" },
          { "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
            "name" => "Verificación de teléfono" },
          { "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
            "name" => "Registro" },
          { "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
            "name" => "Cambio de datos personales" },
          { "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
            "name" => "Verificación de documento" }
        ]
      end
    end

    context "when interval is day" do
      let(:interval) { "day" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "data" => { "2019-06-15 05:00:00 UTC" => 0, "2019-06-15 06:00:00 UTC" => 1 }, "name" => "Registro" },
            { "data" => { "2019-06-15 05:00:00 UTC" => 0, "2019-06-15 06:00:00 UTC" => 1 }, "name" => "Cambio de datos personales" },
            { "data" => { "2019-06-15 05:00:00 UTC" => 0, "2019-06-15 06:00:00 UTC" => 1 }, "name" => "Verificación de documento" },
            { "data" => { "2019-06-15 05:00:00 UTC" => 1, "2019-06-15 06:00:00 UTC" => 0 }, "name" => "Verificación de teléfono" },
            { "data" => { "2019-06-15 05:00:00 UTC" => 0, "2019-06-15 06:00:00 UTC" => 1 }, "name" => "Cambio de nivel de membresía" }
          ]
        end
      end
    end

    context "when interval is week" do
      let(:interval) { "week" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
              "name" => "Cambio de nivel de membresía" },
            { "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
              "name" => "Verificación de teléfono" },
            { "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
              "name" => "Registro" },
            { "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
              "name" => "Cambio de datos personales" },
            { "data" => { "2019-06-10" => 1, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 1 },
              "name" => "Verificación de documento" }
          ]
        end
      end
    end

    context "when interval is month" do
      let(:interval) { "month" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "data" => { "2019-05-19" => 1, "2019-05-26" => 0, "2019-06-02" => 0, "2019-06-09" => 2 }, "name" => "Cambio de nivel de membresía" },
            { "data" => { "2019-05-19" => 1, "2019-05-26" => 0, "2019-06-02" => 0, "2019-06-09" => 2 }, "name" => "Registro" },
            { "data" => { "2019-05-19" => 1, "2019-05-26" => 0, "2019-06-02" => 0, "2019-06-09" => 2 }, "name" => "Verificación de documento" },
            { "data" => { "2019-05-19" => 1, "2019-05-26" => 0, "2019-06-02" => 0, "2019-06-09" => 2 }, "name" => "Verificación de teléfono" },
            { "data" => { "2019-05-19" => 1, "2019-05-26" => 0, "2019-06-02" => 0, "2019-06-09" => 2 }, "name" => "Cambio de datos personales" }
          ]
        end
      end
    end

    context "when interval is year" do
      let(:interval) { "year" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "data" => { "2018-08-01" => 1, "2018-09-01" => 0, "2018-10-01" => 0, "2018-11-01" => 0, "2018-12-01" => 0, "2019-01-01" => 0, "2019-02-01" => 0, "2019-03-01" => 0,
                          "2019-04-01" => 0, "2019-05-01" => 1, "2019-06-01" => 2 },
              "name" => "Cambio de datos personales" },
            { "data" => { "2018-08-01" => 1, "2018-09-01" => 0, "2018-10-01" => 0, "2018-11-01" => 0, "2018-12-01" => 0, "2019-01-01" => 0, "2019-02-01" => 0, "2019-03-01" => 0,
                          "2019-04-01" => 0, "2019-05-01" => 1, "2019-06-01" => 2 },
              "name" => "Verificación de teléfono" },
            { "data" => { "2018-08-01" => 1, "2018-09-01" => 0, "2018-10-01" => 0, "2018-11-01" => 0, "2018-12-01" => 0, "2019-01-01" => 0, "2019-02-01" => 0, "2019-03-01" => 0,
                          "2019-04-01" => 0, "2019-05-01" => 1, "2019-06-01" => 2 },
              "name" => "Verificación de documento" },
            { "data" => { "2018-08-01" => 1, "2018-09-01" => 0, "2018-10-01" => 0, "2018-11-01" => 0, "2018-12-01" => 0, "2019-01-01" => 0, "2019-02-01" => 0, "2019-03-01" => 0,
                          "2019-04-01" => 0, "2019-05-01" => 1, "2019-06-01" => 2 },
              "name" => "Registro" },
            { "data" => { "2018-08-01" => 1, "2018-09-01" => 0, "2018-10-01" => 0, "2018-11-01" => 0, "2018-12-01" => 0, "2019-01-01" => 0, "2019-02-01" => 0, "2019-03-01" => 0,
                          "2019-04-01" => 0, "2019-05-01" => 1, "2019-06-01" => 2 },
              "name" => "Cambio de nivel de membresía" }
          ]
        end
      end
    end
  end

  describe "admins_stats page" do
    subject { get(:admins_stats, params: { format: :json, interval: interval }) }

    around do |example|
      Timecop.freeze(freeze_date) do
        events
        example.run
      end
    end

    let(:freeze_date) { DateTime.civil(2019, 6, 15, 12, 30, 0) }
    let(:interval) { "" }
    let(:admin1) { create(:admin, username: "admin1") }
    let(:admin2) { create(:admin, username: "admin2") }

    let(:events) do
      [10.months, 3.weeks, 5.days, 6.hours].each do |time|
        Timecop.freeze(time.ago) do
          visit1 = create(:visit, admin: admin1)
          visit2 = create(:visit, admin: admin2)
          create(:event, visit: visit1, time: 1.minute.ago)
          create(:event, visit: visit2, time: 10.minutes.ago)
          create(:event, visit: visit1, time: 15.minutes.ago)
          create(:event, visit: visit2, time: 30.minutes.ago)
          create(:event, visit: visit1, time: 45.minutes.ago)
        end
      end
    end

    include_context "with a devise login" do
      let(:current_admin) { create(:admin, :data) }
    end

    it_behaves_like "a stats JSON data endpoint" do
      let(:expected_response) do
        [
          { "data" => { "2019-06-10" => 3, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 3 },
            "name" => "admin1" },
          { "data" => { "2019-06-10" => 2, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 2 },
            "name" => "admin2" }
        ]
      end
    end

    context "when interval is day" do
      let(:interval) { "day" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "data" => { "2019-06-15 05:00:00 UTC" => 1, "2019-06-15 06:00:00 UTC" => 2 }, "name" => "admin1" },
            { "data" => { "2019-06-15 05:00:00 UTC" => 0, "2019-06-15 06:00:00 UTC" => 2 }, "name" => "admin2" }
          ]
        end
      end
    end

    context "when interval is week" do
      let(:interval) { "week" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "data" => { "2019-06-10" => 3, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 3 },
              "name" => "admin1" },
            { "data" => { "2019-06-10" => 2, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 2 },
              "name" => "admin2" }
          ]
        end
      end
    end

    context "when interval is month" do
      let(:interval) { "month" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "data" => { "2019-05-19" => 3, "2019-05-26" => 0, "2019-06-02" => 0, "2019-06-09" => 6 }, "name" => "admin1" },
            { "data" => { "2019-05-19" => 2, "2019-05-26" => 0, "2019-06-02" => 0, "2019-06-09" => 4 }, "name" => "admin2" }
          ]
        end
      end
    end

    context "when interval is year" do
      let(:interval) { "year" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "data" => { "2018-08-01" => 3, "2018-09-01" => 0, "2018-10-01" => 0, "2018-11-01" => 0, "2018-12-01" => 0, "2019-01-01" => 0,
                          "2019-02-01" => 0, "2019-03-01" => 0, "2019-04-01" => 0, "2019-05-01" => 3, "2019-06-01" => 6 },
              "name" => "admin1" },
            { "data" => { "2018-08-01" => 2, "2018-09-01" => 0, "2018-10-01" => 0, "2018-11-01" => 0, "2018-12-01" => 0, "2019-01-01" => 0,
                          "2019-02-01" => 0, "2019-03-01" => 0, "2019-04-01" => 0, "2019-05-01" => 2, "2019-06-01" => 4 },
              "name" => "admin2" }
          ]
        end
      end
    end
  end

  describe "orders_stats page" do
    subject { get(:orders_stats, params: { format: :json, interval: interval }) }

    around do |example|
      Timecop.freeze(freeze_date) do
        orders
        example.run
      end
    end

    let(:freeze_date) { DateTime.civil(2019, 6, 15, 12, 30, 0) }
    let(:interval) { "" }

    let(:orders) do
      [10.months, 3.weeks, 5.days, 6.hours].each do |time|
        Timecop.freeze(time.ago) do
          create(:order, created_at: 1.minute.ago)
          create(:order, :processed, created_at: 10.minutes.ago)
          create(:order, created_at: 15.minutes.ago)
          create(:order, :processed, created_at: 30.minutes.ago)
          create(:order, created_at: 45.minutes.ago)
        end
      end
    end

    include_context "with a devise login" do
      let(:current_admin) { create(:admin, :finances) }
    end

    it_behaves_like "a stats JSON data endpoint" do
      let(:expected_response) do
        [
          { "data" => { "2019-06-10" => 2, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 2 },
            "name" => "Pagada" },
          { "data" => { "2019-06-10" => 3, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 3 },
            "name" => "Pendiente" }
        ]
      end
    end

    context "when interval is day" do
      let(:interval) { "day" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "data" => { "2019-06-15 05:00:00 UTC" => 0, "2019-06-15 06:00:00 UTC" => 2 }, "name" => "Pagada" },
            { "data" => { "2019-06-15 05:00:00 UTC" => 1, "2019-06-15 06:00:00 UTC" => 2 }, "name" => "Pendiente" }
          ]
        end
      end
    end

    context "when interval is week" do
      let(:interval) { "week" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "data" => { "2019-06-10" => 2, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 2 },
              "name" => "Pagada" },
            { "data" => { "2019-06-10" => 3, "2019-06-11" => 0, "2019-06-12" => 0, "2019-06-13" => 0, "2019-06-14" => 0, "2019-06-15" => 3 },
              "name" => "Pendiente" }
          ]
        end
      end
    end

    context "when interval is month" do
      let(:interval) { "month" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "data" => { "2019-05-19" => 2, "2019-05-26" => 0, "2019-06-02" => 0, "2019-06-09" => 4 }, "name" => "Pagada" },
            { "data" => { "2019-05-19" => 3, "2019-05-26" => 0, "2019-06-02" => 0, "2019-06-09" => 6 }, "name" => "Pendiente" }
          ]
        end
      end
    end

    context "when interval is year" do
      let(:interval) { "year" }

      it_behaves_like "a stats JSON data endpoint" do
        let(:expected_response) do
          [
            { "data" => { "2018-08-01" => 2, "2018-09-01" => 0, "2018-10-01" => 0, "2018-11-01" => 0, "2018-12-01" => 0, "2019-01-01" => 0,
                          "2019-02-01" => 0, "2019-03-01" => 0, "2019-04-01" => 0, "2019-05-01" => 2, "2019-06-01" => 4 },
              "name" => "Pagada" },
            { "data" => { "2018-08-01" => 3, "2018-09-01" => 0, "2018-10-01" => 0, "2018-11-01" => 0, "2018-12-01" => 0, "2019-01-01" => 0,
                          "2019-02-01" => 0, "2019-03-01" => 0, "2019-04-01" => 0, "2019-05-01" => 3, "2019-06-01" => 6 },
              "name" => "Pendiente" }
          ]
        end
      end
    end
  end
end
