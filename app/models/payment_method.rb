# frozen_string_literal: true

class PaymentMethod < ApplicationRecord
  include FlagShihTzu

  self.inheritance_column = :type

  has_flags 1 => :verified,
            2 => :has_issues,
            3 => :failing,
            check_for_column: false

  acts_as_paranoid
  has_paper_trail

  belongs_to :person

  before_save :remove_issues!, if: :issues_fixed?

  def active?
    !deleted? && !failing?
  end

  def processed_ok
    assign_attributes verified: true, has_issues: false, failing: false
  end

  def processed_warn
    assign_attributes has_issues: true
  end

  def processed_errors
    assign_attributes has_issues: true, failing: true
  end

  def remove_issues
    assign_attributes has_issues: false
  end

  def issues_fixed?
    has_issues? && information_changed?
  end
end
