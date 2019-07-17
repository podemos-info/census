# frozen_string_literal: true

namespace :census do
  desc "Refresh precalculated column on models with fast filter support"
  task :refresh_fast_filters, [] => :environment do
    [Person, Procedure].each do |klass|
      klass.find_each do |resource|
        resource.calculate_fast_filter

        # rubocop:disable Rails/SkipsModelValidations
        resource.update_column(:fast_filter, resource.fast_filter) if resource.has_changes_to_save?
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
