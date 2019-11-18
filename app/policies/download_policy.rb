# frozen_string_literal: true

class DownloadPolicy < ApplicationPolicy
  def base_role?
    !download_instance? || for_me? || user.data_role?
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    base_role? && !(download_instance? && record.discarded?)
  end

  def recover?
    base_role? && download_instance? && record.discarded?
  end

  def download?
    base_role?
  end

  def for_me?
    download_instance? && user.person == record.person
  end

  private

  def download_instance?
    !record.is_a?(Class) && record.person.present?
  end
end
