# frozen_string_literal: true

class Procedure < ApplicationRecord
  include AASM

  has_paper_trail

  self.inheritance_column = :type
  belongs_to :person
  belongs_to :processed_by, class_name: "Person", optional: true
  belongs_to :depends_on, class_name: "Procedure", optional: true

  has_many :dependent_procedures,
           foreign_key: "depends_on_id",
           class_name: "Procedure",
           inverse_of: :depends_on
  has_many :attachments

  scope :independent, -> { where depends_on: nil }

  validates :comment, presence: { message: I18n.t("errors.messages.procedure_denial_comment_required") },
                      if: proc { |procedure| procedure.issues? || procedure.rejected? }
  validates :processed_by, :processed_at, presence: true, if: :processed?
  validate :processed_by, :processor_different_from_person
  validate :depends_on, :depends_on_person

  aasm column: :state do
    state :pending, initial: true
    state :issues, :accepted, :rejected

    event :accept do
      transitions from: [:pending, :issues], to: :accepted, if: :acceptable?

      after do
        after_accepted
      end
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

  def initialize(*args)
    raise "Cannot directly instantiate a Procedure" if self.class == Procedure
    super
  end

  # START overridable methods
  def after_accepted; end

  def if_accepted
    yield
  end

  def permitted_events
    @permitted_events ||= aasm.events(permitted: true).map(&:name)
  end

  def check_acceptable
    true
  end

  def undo; end
  # END overridable methods

  def acceptable?
    check_acceptable && if_accepted do
      dependent_procedures.all? do |dependent_procedure|
        dependent_procedure.person = person
        dependent_procedure.acceptable?
      end
    end
  end

  def processed?
    accepted? || rejected?
  end

  def processable?
    !processed?
  end

  def undoable?
    processed_at && processed_at > Settings.undo_minutes.minutes.ago &&
      undo_version && dependent_procedures.all?(&:undoable?)
  end

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

  private

  def processor_different_from_person
    errors.add(:processed_by_id, :processed_by_person) if processed_by == person
  end

  def depends_on_person
    errors.add(:depends_on_id, :depends_on_different_person) if depends_on && depends_on.person != person
  end
end
