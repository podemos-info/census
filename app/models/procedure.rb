# frozen_string_literal: true

class Procedure < ApplicationRecord
  include ProcedureStates

  self.inheritance_column = :type

  has_paper_trail

  belongs_to :person
  belongs_to :processed_by, class_name: "Admin", optional: true
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
  validate :processed_by, :processed_by_different_from_person
  validate :depends_on, :depends_on_person

  def initialize(*args)
    raise "Cannot directly instantiate a Procedure" if self.class == Procedure
    super
  end

  private

  def processed_by_different_from_person
    errors.add(:processed_by_id, :processed_by_person) if processed_by&.person == person
  end

  def depends_on_person
    errors.add(:depends_on_id, :depends_on_different_person) unless depends_on.nil? || depends_on.person == person
  end
end
