# frozen_string_literal: true

module CanHavePerson
  extend ActiveSupport::Concern

  included do
    attribute :person_id, Integer

    def person
      return @person if defined? @person
      @person = Person.find_by(id: person_id)
    end
  end
end
