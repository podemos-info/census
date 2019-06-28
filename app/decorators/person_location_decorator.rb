# frozen_string_literal: true

class PersonLocationDecorator < ApplicationDecorator
  delegate_all

  decorates_association :person

  def name
    "#{created_at.to_s(:db)} - #{ip}"
  end
end
