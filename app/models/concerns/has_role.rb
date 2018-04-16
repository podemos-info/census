# frozen_string_literal: true

module HasRole
  extend ActiveSupport::Concern
  included do
    enum role: [:system, :lopd, :lopd_help, :finances], _suffix: true

    def lopd_help_role?
      super || lopd_role?
    end

    def role_includes?(has_role)
      (role == has_role.role) || (lopd_role? && has_role.lopd_help_role?)
    end
  end
end
