# frozen_string_literal: true

class Procedure < ApplicationRecord
  include ProcedureStates
  include Issuable

  self.inheritance_column = :type

  belongs_to :person
  belongs_to :processed_by, class_name: "Admin", optional: true
  belongs_to :depends_on, class_name: "Procedure", optional: true

  has_paper_trail class_name: "Version"
  has_many :versions, as: :item

  has_many :dependent_procedures,
           foreign_key: "depends_on_id",
           class_name: "Procedure",
           inverse_of: :depends_on
  has_many :attachments

  scope :independent, -> { where depends_on: nil }

  validates :comment, presence: { message: I18n.t("errors.messages.procedure_denial_comment_required") },
                      if: proc { |procedure| procedure.issues? || procedure.rejected? }
  validates :processed_by, :processed_at, presence: true, if: :processed?
  validate :processed_by, :processed_by_different_from_person
  validate :depends_on, :depends_on_person

  def process_reject; end

  def undo_reject; end

  def persist_reject_changes!; end

  def processable?
    !processed? && issues_summary != :pending
  end

  def auto_processable?
    self.class.auto_processable? && processable?
  end

  def self.auto_processable?
    @auto_processable ||= Settings.procedures.auto_processables.include?(name.demodulize.underscore)
  end

  private

  def processed_by_different_from_person
    errors.add(:processed_by_id, :processed_by_person) if processed_by&.person == person
  end

  def depends_on_person
    errors.add(:depends_on_id, :depends_on_different_person) unless depends_on.nil? || depends_on.person == person
  end
end
