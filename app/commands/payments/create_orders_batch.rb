# frozen_string_literal: true

module Payments
  # A command to create a batch of orders
  class CreateOrdersBatch < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    # admin - The admin user creating the orders_batch.
    def initialize(form:, admin: nil)
      @form = form
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything was ok. Includes the created orders batch.
    # - :invalid when the orders batch data is invalid.
    # - :error if the orders batch couldn't be created.
    #
    # Returns nothing.

    def call
      return broadcast(:invalid) unless form&.valid?

      broadcast(create_orders_batch || :error, orders_batch: orders_batch)
    end

    private

    attr_reader :form

    def orders_batch
      @orders_batch ||= OrdersBatch.new description: form.description
    end

    def create_orders_batch
      OrdersBatch.transaction do
        orders_batch.save!
        form.orders.each do |order|
          order.orders_batch = orders_batch
          order.save!
        end

        :ok
      end
    end
  end
end
