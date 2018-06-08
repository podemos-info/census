# frozen_string_literal: true

namespace :census do
  desc "Update person state machines graphs"
  task update_person_states_graphs: :environment do
    require "aasm-diagram"
    [:state, :membership_level, :verification].each do |machine|
      AASMDiagram::Diagram.new(Person.new.aasm(machine), "docs/#{machine}s.png")
    end
  end
end
