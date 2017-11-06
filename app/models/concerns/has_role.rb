# frozen_string_literal: true

module HasRole
  extend ActiveSupport::Concern
  included do
    enum role: [:system, :lopd, :lopd_help, :finances], _suffix: true

    def lopd_help_role?
      super || lopd_role?
    end
  end
end
