# frozen_string_literal: true

ActiveAdmin.register OrdersBatch do
  decorate_with OrdersBatchDecorator
  menu parent: :orders

  index do
    id_column
    column :description, class: :left
    column :processed_with
    column :orders_count
    actions defaults: true do |orders_batch|
      link_to t("census.orders_batch.process"), process_batch_orders_batch_path(orders_batch), method: :patch,
                                                                                               data: { confirm: t("census.sure_question") },
                                                                                               class: :member_link
    end
  end

  member_action :process_batch, method: :patch do
    orders_batch = resource
    Payments::ProcessOrdersBatch.call(orders_batch, current_user) do
      on(:invalid) do
        flash[:error] = t("census.orders_batch.action_message.not_processed").html_safe
      end
      on(:ok) do
        flash[:notice] = t("census.orders_batch.action_message.processed").html_safe
      end
    end
    redirect_back(fallback_location: orders_batch_path)
  end
end
