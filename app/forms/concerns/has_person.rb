# frozen_string_literal: true

module HasPerson
  extend ActiveSupport::Concern

  included do
    attribute :person_id, Integer
    validates :person_id, :person, presence: true

    def person
      return @person if defined? @person
      @person = Person.find_by(id: person_id)
    end
  end
end
