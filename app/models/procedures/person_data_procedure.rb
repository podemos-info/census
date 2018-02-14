# frozen_string_literal: true

module Procedures
  class PersonDataProcedure < Procedure
    store_accessor :information, :person_data

    delegate :first_name, :last_name1, :last_name2, to: :person_data_object
    delegate :document_type, :document_id, :document_scope_id, to: :person_data_object
    delegate :phone, :email, to: :person_data_object
    delegate :address, :address_scope_id, :postal_code, to: :person_data_object
    delegate :scope_id, :membership_level, :gender, :born_at, to: :person_data_object

    validates :person_data, presence: true

    private

    def person_data_object
      @person_data_object ||= OpenStruct.new(person_data)
    end
  end
end
