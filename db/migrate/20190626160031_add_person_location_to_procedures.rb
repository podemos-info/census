# frozen_string_literal: true

class AddPersonLocationToProcedures < ActiveRecord::Migration[5.2]
  def change
    add_reference :procedures, :person_location
  end
end
