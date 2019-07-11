# frozen_string_literal: true

module FastFilter
  extend ActiveSupport::Concern

  class_methods do
    FILTERABLE_ATTRIBUTES = {
      person: [:first_name, :last_name1, :last_name2, :document_id, :born_at, :postal_code, :email, :phone],
      procedure: [:information],
      scope: [:name, :code]
    }.freeze

    def against_attributes
      FILTERABLE_ATTRIBUTES[name.downcase.to_sym]
    end

    def associated_against_attributes(parents = 5)
      ret = {}

      FILTERABLE_ATTRIBUTES.each do |key, attributes|
        ret[key] = attributes if instance_methods.include?(key)
      end

      if instance_methods.include?(:scope)
        has_one :scope_parent1, through: :scope, source: :parent, class_name: "Scope"
        (2..parents).each do |i|
          has_one :"scope_parent#{i}", through: :"scope_parent#{i - 1}", source: :parent, class_name: "Scope"
        end

        (1..parents).map { |i| :"scope_parent#{i}" }.each do |key|
          ret[key] = FILTERABLE_ATTRIBUTES[:scope]
        end
      end

      ret
    end
  end

  included do
    include PgSearch

    pg_search_scope :fast_filter,
                    using: {
                      tsearch: {
                        prefix: true,
                        dictionary: "simple"
                      }
                    },
                    against: against_attributes,
                    associated_against: associated_against_attributes
  end
end
