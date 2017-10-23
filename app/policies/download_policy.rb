# frozen_string_literal: true

class DownloadPolicy < ApplicationPolicy
  def base_role?
    user.lopd_role? || super
  end

  def create?
    false
  end

  def update?
    false
  end

  def download?
    base_role?
  end
end
