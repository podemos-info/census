# frozen_string_literal: true

class Procedure < ApplicationRecord
  include AASM

  has_paper_trail

  self.inheritance_column = :type
  belongs_to :person
  belongs_to :processed_by, class_name: "Person", optional: true

  has_many :attachments

  scope :history, -> { order created_at: :desc }

  validates :comment, presence: { message: I18n.t("errors.messages.procedure_denial_comment_required") }, 
                      if: Proc.new { |procedure| procedure.issues? || procedure.rejected? }
  validates :processed_by, :processed_at, presence: true, if: Proc.new { |procedure| procedure.accepted? || procedure.rejected? }

  aasm column: :state do
    state :pending, initial: true
    state :accepted, :issues, :rejected

    event :accept do
      transitions from: [:pending, :issues], to: :accepted
    end

    event :set_issues do
      transitions from: :pending, to: :issues
    end

    event :reject do
      transitions from: [:pending, :issues], to: :rejected
    end

    event :undo do
      transitions from: [:accepted, :rejected], to: :pending, if: :undoable?
    end
  end

  def processable?
    pending? || issues?
  end

  def undoable?
    processed_at && processed_at > Settings.undo_minutes.minutes.ago
  end
end
