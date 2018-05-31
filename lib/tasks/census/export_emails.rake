# frozen_string_literal: true

namespace :census do
  desc "Export people emails"
  task :export_emails, [] => :environment do
    puts %w(ID Email Name Scope Address).to_csv
    Person.enabled.includes(:scope, :address_scope).find_each do |person|
      puts [person.id, person.email, person.phone, person.first_name, person.scope.code, person.address_scope.code].to_csv
    end
  end
end
