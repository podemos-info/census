# frozen_string_literal: true

class PayeeDecorator < ApplicationDecorator
  delegate_all

  decorates_association :scope

  delegate :name, to: :object

  alias to_s name
  alias listable_name name

  def full_scope
    scope&.full_path
  end
end
