# frozen_string_literal: true

module AdditionalInformation
  extend ActiveSupport::Concern

  included do
    def additional_information
      Hash[self.class.additional_information_names.map { |field| [field, send(field)] }]
    end
  end

  module ClassMethods
    @additional_information_names = []

    def additional_information(*names)
      @additional_information_names = names
    end

    def additional_information_names
      @additional_information_names
    end
  end
end
