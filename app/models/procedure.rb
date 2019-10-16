# frozen_string_literal: true

class Procedure < ApplicationRecord
  include FastFilter
  include Issuable
  include ProcedureStates

  self.inheritance_column = :type

  belongs_to :person
  belongs_to :processing_by, class_name: "Admin", optional: true
  belongs_to :processed_by, class_name: "Admin", optional: true
  belongs_to :person_location, optional: true

  has_many :versions, as: :item, dependent: :destroy, inverse_of: :item
  has_many :attachments, dependent: :destroy

  has_paper_trail versions: { class_name: "Version" }, skip: [:fast_filter, :lock_version, :processing_by, :processing_at]

  validates :comment, presence: { message: I18n.t("errors.messages.procedure_denial_comment_required") }, if: :rejected?
  validates :processed_at, presence: true, if: :processed?
  validate :processed_by, :processed_by_different_from_person

  before_save :update_processing_at

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
    errors.add(:processing_by_id, :processed_by_person) if processing_by&.person == person
    errors.add(:processed_by_id, :processed_by_person) if processed_by&.person == person
  end

  def update_processing_at
    return unless processing_by_id_changed?

    self.processing_at = processing_by ? Time.current : nil
  end
end
