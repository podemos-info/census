# frozen_string_literal: true

ActiveAdmin.register OrdersBatch do
  decorate_with OrdersBatchDecorator
  menu parent: :orders

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

  show do
    attributes_table do
      row :id
      row :description
      row :orders_count
      row :created_at
      row :updated_at
    end
  end

  member_action :charge, method: :patch do # Fails when calling it :process
    orders_batch = resource
    Payments::ProcessOrdersBatch.call(orders_batch, current_user) do
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
