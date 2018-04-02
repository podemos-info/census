# frozen_string_literal: true

module Procedures
  class PersonDataProcedure < Procedure
    store_accessor :information, :person_data, :from_person_data

    delegate :first_name, :last_name1, :last_name2, to: :person_data_object
    delegate :document_type, :document_id, :document_scope_id, to: :person_data_object
    delegate :phone, :email, to: :person_data_object
    delegate :address, :address_scope_id, :postal_code, to: :person_data_object
    delegate :scope_id, :membership_level, :gender, to: :person_data_object

    validates :person_data, presence: true

    def born_at
      @born_at ||= person_data_object.born_at&.to_date
    end

    def set_from_person_data
      self.from_person_data = Hash[
        person_data.keys.map do |attribute|
          [attribute, person.send(attribute)]
        end
      ]
    end

    private

    def person_data_object
      @person_data_object ||= OpenStruct.new(person_data)
    end
  end
end
