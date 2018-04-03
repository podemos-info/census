# frozen_string_literal: true

module CanHavePerson
  extend ActiveSupport::Concern

  included do
    attribute :qualified_id, Integer
    attribute :person_id, Integer

    def person
      return @person if defined? @person

      @person = if qualified_id
                  Person.qualified_find(qualified_id)
                elsif person_id
                  Person.find_by(id: person_id)
                end
    end
  end
end
