# frozen_string_literal: true

class PayeeDecorator < ApplicationDecorator
  delegate_all

  decorates_association :scope

  def full_scope
    scope&.show_path
  end
end
