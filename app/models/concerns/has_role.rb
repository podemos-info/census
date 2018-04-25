# frozen_string_literal: true

module HasRole
  extend ActiveSupport::Concern
  included do
    enum role: [:system, :data, :data_help, :finances], _suffix: true

    def data_help_role?
      super || data_role?
    end

    def role_includes?(has_role)
      (role == has_role.role) || (data_role? && has_role.data_help_role?)
    end
  end
end
