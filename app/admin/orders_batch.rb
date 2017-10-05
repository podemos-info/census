# frozen_string_literal: true

ActiveAdmin.register OrdersBatch do
  decorate_with OrdersBatchDecorator

  menu parent: I18n.t("active_admin.payments")

  actions :index, :show

  index do
    id_column
    column :description, class: :left
    column :orders_count
    actions
  end

  action_item :process, only: :show do
    link_to t("census.orders_batches.process"), charge_orders_batch_path(orders_batch), method: :patch,
                                                                                        data: { confirm: t("census.sure_question") },
                                                                                        class: :member_link
  end

  sidebar :versions, partial: "orders_batches/versions", only: :show

  show do
    render "show", context: self, classes: classed_changeset(resource.versions.last, "version_change")
    active_admin_comments
  end

  member_action :charge, method: :patch do # Fails when calling it :process
    orders_batch = resource
    Payments::ProcessOrdersBatch.call(orders_batch, current_admin) do
      on(:invalid) do
        flash[:error] = t("census.orders_batches.action_message.not_processed")
      end
      on(:issues) do
        flash[:warning] = t("census.orders_batches.action_message.issues")
      end
      on(:ok) do
        flash[:notice] = t("census.orders_batches.action_message.processed")
      end
    end
    redirect_back(fallback_location: orders_batches_path)
  end
end
