# frozen_string_literal: true

require "simplecov"
SimpleCov.start "rails" do
  add_group "Admin", "app/admin"
  add_group "Commands", "app/commands"
  add_group "Decorators", "app/decorators"
  add_group "Forms", "app/forms"
  add_group "Policies", "app/policies"
  add_group "Queries", "app/queries"
end
