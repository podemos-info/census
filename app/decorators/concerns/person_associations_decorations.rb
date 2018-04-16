# frozen_string_literal: true

module PersonAssociationsDecorations
  extend ActiveSupport::Concern

  included do
    def independent_procedures
      @independent_procedures ||= PersonIndependentProcedures.for(object).decorate(context: context)
    end

    def last_procedures
      @last_procedures ||= PersonLastIndependentProcedures.for(object).decorate(context: context)
    end

    def count_procedures
      @count_procedures ||= independent_procedures.count
    end

    def last_orders
      @last_orders ||= PersonLastOrders.for(object).decorate(context: context)
    end

    def count_orders
      @count_orders ||= object.orders.count
    end

    def count_payment_methods
      @count_payment_methods ||= object.payment_methods.count
    end

    def last_downloads
      @last_downloads ||= PersonLastActiveDownloads.for(object).decorate(context: context)
    end
  end
end
