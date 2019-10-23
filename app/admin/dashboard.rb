# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    Chartkick.options = {
      download: true,
      legend: :bottom
    }

    page_policy = policy(ActiveAdmin::Page)

    if page_policy.procedures_stats?
      panel helpers.model_name(Procedure, count: 2), id: "procedures_stats" do
        columns do
          column span: 2 do
            h4 "Creados"
            div line_chart dashboard_procedures_stats_path(format: :json, interval: controller.interval)
          end
          column do
            h4 "Pendientes"
            div id: "pending_procedures" do
              div pie_chart controller.pending_procedures_stats_data, donut: true
              a href: next_document_verification_procedures_path do
                div controller.pending_procedures_stats_data.values.sum
                span t("census.procedures.process"), class: "button"
              end
            end
          end
        end
      end
    end

    if page_policy.people_stats?
      panel helpers.model_name(Person, count: 2), id: "people_stats" do
        line_chart dashboard_people_stats_path(format: :json, interval: controller.interval)
      end
    end

    if page_policy.admins_stats?
      panel helpers.model_name(Admin, count: 2), id: "admins_stats" do
        line_chart dashboard_admins_stats_path(format: :json, interval: controller.interval)
      end
    end

    if page_policy.orders_stats?
      panel helpers.model_name(Order, count: 2), id: "orders_stats" do
        line_chart dashboard_orders_stats_path(format: :json, interval: controller.interval)
      end
    end
  end

  action_item :interval_selector do
    select onchange: "location.replace(this.value)", class: "default-select" do
      [:day, :week, :month, :year].each do |interval|
        option(value: "/?interval=#{interval}", selected: controller.interval == interval) do
          t("census.dashboard.intervals.#{interval}")
        end
      end
    end
  end

  page_action :people_stats do
    render json: people_stats_data, type: "application/json"
  end

  page_action :procedures_stats do
    render json: procedures_stats_data, type: "application/json"
  end

  page_action :orders_stats do
    render json: orders_stats_data, type: "application/json"
  end

  page_action :admins_stats do
    render json: admins_stats_data, type: "application/json"
  end

  controller do
    def people_stats_data
      [
        { name: helpers.state_name(Person, :state, :pending).capitalize,
          data: Person.where(created_at: dates_interval).pending.send(group_by, :created_at).count,
          color: :orange },
        { name: helpers.state_name(Person, :state, :enabled).capitalize,
          data: Person.where(created_at: dates_interval).enabled.send(group_by, :created_at).count,
          color: :green },
        { name: helpers.state_name(Person, :membership_level, :member).capitalize,
          data: Person.where(created_at: dates_interval).enabled.member.send(group_by, :created_at).count,
          color: "#683064" },
        { name: helpers.state_name(Person, :state, :cancelled).capitalize,
          data: Person.where(discarded_at: dates_interval).cancelled.send(group_by, :discarded_at).count,
          color: :red },
        { name: helpers.state_name(Person, :state, :trashed).capitalize,
          data: Person.where(discarded_at: dates_interval).trashed.send(group_by, :discarded_at).count,
          color: :gray }
      ]
    end

    def procedures_stats_data
      format_data(Procedure.where(created_at: dates_interval).group(:type).send(group_by, :created_at).count) do |name, _|
        helpers.model_name(name)
      end
    end

    def pending_procedures_stats_data
      @pending_procedures_stats_data ||= {
        t("active_admin.resources.procedure.scopes.without_open_issues") => Procedure.pending.without_open_issues.count,
        t("active_admin.resources.procedure.scopes.with_open_issues") => Procedure.pending.with_open_issues.count
      }
    end

    def orders_stats_data
      format_data(Order.where(created_at: dates_interval).group(:state).send(group_by, :created_at).count) do |name, _|
        helpers.state_name(Order, :state, name)
      end
    end

    def admins_stats_data
      format_data(*prefetch_admins(Event.where(time: dates_interval).group(:admin_id).send(group_by, :time).count)) do |name, context|
        context.dig(:admins, name) || t("census.dashboard.admins.unknown")
      end
    end

    def interval
      @interval = params[:interval]&.to_sym.presence || :week
    end

    def dates_interval
      case interval
      when :day then 1.day.ago..1.day.from_now
      when :week then 1.week.ago..1.day.from_now
      when :month then 1.month.ago..1.day.from_now
      when :year then 1.year.ago..1.day.from_now
      end
    end

    def group_by
      case interval
      when :day then :group_by_hour
      when :week then :group_by_day
      when :month then :group_by_week
      when :year then :group_by_month
      end
    end

    def format_data(raw_data, context: {})
      raw_data.group_by { |key, _| key[0] } .map do |name, series|
        {
          name: yield(name, context),
          data: Hash[series.map { |key2, value| [key2[1], value] }]
        }
      end
    end

    def prefetch_admins(raw_data)
      [raw_data, context: { admins: Hash[Admin.where(id: raw_data.map(&:first).map(&:first)).pluck(:id, :username)] }]
    end
  end
end
