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
                      if: proc { |procedure| procedure.issues? || procedure.rejected? }
  validates :processed_by, :processed_at, presence: true, if: proc { |procedure| procedure.accepted? || procedure.rejected? }

  aasm column: :state do
    state :pending, initial: true
    state :issues, :accepted, :rejected

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

      after do
        self.state = undo_version.state
        self.processed_by = undo_version.processed_by
        self.processed_at = undo_version.processed_at
        self.comment = undo_version.comment
      end
    end
  end

  def initialize(*args)
    raise "Cannot directly instantiate a Procedure" if self.class == Procedure
    super
  end

  def processed?
    accepted? || rejected?
  end

  def processable?
    !processed?
  end

  def undoable?
    processed_at && processed_at > Settings.undo_minutes.minutes.ago && undo_version
  end

  private

  def undo_version
    defined?(@undo_version) ||
      versions.reverse.each do |version|
        previous_version = version.reify
        if previous_version&.state && previous_version&.state != state
          @undo_version = previous_version
          break
        end
      end
    @undo_version
  end
end
