# frozen_string_literal: true

module ActiveAdmin
  class CommentPolicy < ApplicationPolicy
    def base_role?
      true
    end

    def index?
      false
    end

    def destroy?
      false
    end

    def update?
      false
    end
  end
end
