# frozen_string_literal: true

module ActiveAdmin
  class PagePolicy < ApplicationPolicy
    def show?
      case record.name
      when "Dashboard"
        true
      else
        false
      end
    end

    def people_stats?
      user.data_role?
    end

    def procedures_stats?
      user.data_help_role?
    end

    def orders_stats?
      user.finances_role?
    end

    def admins_stats?
      user.system_role?
    end
  end
end
