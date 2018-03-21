# frozen_string_literal: true

class BicDecorator < ApplicationDecorator
  delegate_all

  def name
    "#{country} - #{bank_code}"
  end

  alias to_s name
  alias listable_name name

  def name_link
    h.link_to name, object
  end

  delegate :bic, to: :object
end
