# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

desc "Update state machines graphs"
task update_aasm_graphs: :environment do
  require "aasm-diagram"
  [:state, :membership_level, :verification].each do |machine|
    p machine
    AASMDiagram::Diagram.new(Person.new.aasm(machine), "docs/#{machine}s.png")
  end
end

Rails.application.load_tasks
