# frozen_string_literal: true

module Procedures
  class PersonDataProcedure < Procedure
    store_accessor :information, :person_data, :from_person_data
    validates :person_data, presence: true

    delegate :first_name, :last_name1, :last_name2, to: :person_data_object
    delegate :document_type, :document_id, :document_scope_id, to: :person_data_object
    delegate :phone, :email, to: :person_data_object
    delegate :address, :address_scope_id, :postal_code, to: :person_data_object
    delegate :scope_id, :membership_level, :gender, to: :person_data_object

    def born_at
      @born_at ||= person_data_object.born_at&.to_date
    end

    def fast_filter_contents
      [
        first_name,
        last_name1,
        last_name2,
        document_id,
        born_at,
        postal_code,
        email,
        phone
      ] + super
    end

    def reload
      @born_at = @person_data_object = nil
      super
    end

    protected

    def person_data_object
      @person_data_object ||= OpenStruct.new(person_data)
    end
  end
end
