# frozen_string_literal: true

module HasPerson
  extend ActiveSupport::Concern

  included do
    include CanHavePerson

    validates :person_id, :person, presence: true
  end
end
