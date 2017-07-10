# frozen_string_literal: true

class Procedure < ApplicationRecord
  self.inheritance_column = :type
  belongs_to :person
  belongs_to :processed_by, class_name: "Person", optional: true

  has_many :attachments

  scope :pending, -> { where result: nil }
  scope :history, -> { order created_at: :desc }

  validates :result_comment, presence: { message: I18n.t("errors.messages.procedure_denial_comment_required") }, if: :denied?

  def pending?
    result.nil?
  end

  def approve!
    self.result = true
    save!
  end

  def deny!
    self.result = false
    save!
  end

  def denied?
    result == false
  end
end
