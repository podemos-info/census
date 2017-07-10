# frozen_string_literal: true

class ProcedureDecorator < ApplicationDecorator
  delegate_all

  def to_s
    "#{type_name} - #{person.full_name}"
  end

  def person
    object.person.decorate
  end

  def processed_by
    object.processed_by&.decorate
  end

  def result_name
    object.result.nil? ? "pending" : object.result
  end

  def type_name
    object.model_name.human
  end
end
