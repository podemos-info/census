# frozen_string_literal: true

class ProcessOrdersBatchJob < ApplicationJob
  queue_as :finances

  def related_objects
    [
      arguments.first&.fetch(:orders_batch, nil)
    ].compact
  end

  def perform(orders_batch:, admin:)
    Payments::ProcessOrdersBatch.call(orders_batch: orders_batch, admin: admin) do
      on(:invalid) { self.result = :invalid }
      on(:review) { self.result = :review }
      on(:error) { self.result = :error }
      on(:ok) { self.result = :ok }

      on(:processor_ok) { |info| log :user, key: "process_orders_batch_job.processor_completed", related: [info[:processor]] }
      on(:processor_aborted) { |info| log :user, key: "process_orders_batch_job.processor_aborted", related: [info[:processor]] }
      on(:processor_error) { |info| log :user, key: "process_orders_batch_job.processor_error", related: [info[:processor]] }

      on(:unprocessable_order) { |info| log :user, key: "process_orders_batch_job.unprocessable_order", related: [info[:order].to_gid_param] }
      on(:order_error) { |info| log :user, key: "process_orders_batch_job.order_error", related: [info[:order].to_gid_param] }
      on(:order_issues) { |info| log :user, key: "process_orders_batch_job.order_issues", related: [info[:order].to_gid_param] }
      on(:order_ok) { |info| log :user, key: "process_orders_batch_job.order_ok", related: [info[:order].to_gid_param] }
    end
  end
end
