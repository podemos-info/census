# frozen_string_literal: true

require_relative "config/application"

require "sneakers/tasks"

desc "Update state machines graphs"
task update_aasm_graphs: :environment do
  require "aasm-diagram"
  [:state, :membership_level, :verification].each do |machine|
    p machine
    AASMDiagram::Diagram.new(Person.new.aasm(machine), "docs/#{machine}s.png")
  end
end

Rails.application.load_tasks
