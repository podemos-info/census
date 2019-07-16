# frozen_string_literal: true

class Procedure < ApplicationRecord
  include FastFilter
  include Issuable
  include ProcedureStates

  self.inheritance_column = :type

  belongs_to :person
  belongs_to :processed_by, class_name: "Admin", optional: true
  belongs_to :depends_on, class_name: "Procedure", optional: true
  belongs_to :person_location, optional: true

  has_paper_trail versions: { class_name: "Version" }, skip: [:fast_filter]

  has_many :versions, as: :item, dependent: :destroy, inverse_of: :item
  has_many :dependent_procedures,
           foreign_key: "depends_on_id",
           class_name: "Procedure",
           dependent: :restrict_with_exception,
           inverse_of: :depends_on
  has_many :attachments, dependent: :destroy

  scope :independent, -> { where depends_on: nil }

  validates :comment, presence: { message: I18n.t("errors.messages.procedure_denial_comment_required") }, if: :rejected?
  validates :processed_at, presence: true, if: :processed?
  validate :processed_by, :processed_by_different_from_person
  validate :depends_on, :depends_on_person

  def process_reject; end

  def undo_reject; end

  def processable?
    pending? && !processed? && issues_summary != :pending
  end

  def auto_processable?
    self.class.auto_processable? && processable?
  end

  def issues_summary
    @issues_summary ||= begin
      ret = :ok
      issues.each do |issue|
        if issue.open?
          ret = :pending
        elsif !issue.gone? && !issue.fixed_for?(self)
          ret = :unrecoverable
          break
        end
      end
      ret
    end
  end

  def self.auto_processable?
    @auto_processable ||= Settings.procedures.auto_processables.include?(name.demodulize.underscore)
  end

  def self.policy_class
    ProcedurePolicy
  end

  delegate :fast_filter_contents, to: :person

  private

  def processed_by_different_from_person
    errors.add(:processed_by_id, :processed_by_person) if processed_by&.person == person
  end

  def depends_on_person
    errors.add(:depends_on_id, :depends_on_different_person) unless depends_on.nil? || depends_on.person == person
  end
end
