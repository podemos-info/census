# frozen_string_literal: true

module Payments
  # A command to create a batch of orders
  class CreateOrdersBatch < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    # description - The description of the orders batch
    # orders - Orders to be included in the batch
    def initialize(form)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the batch couldn't be created.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form.valid?

      result = OrdersBatch.transaction do
        orders_batch.save!

        form.orders.find_each do |order|
          order.orders_batch = orders_batch
          order.save!
        end

        :ok
      end

      broadcast result || :invalid
    end

    private

    attr_reader :form

    def orders_batch
      @orders_batch ||= OrdersBatch.new description: form.description
    end
  end
end
