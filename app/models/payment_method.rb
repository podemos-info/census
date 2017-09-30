# frozen_string_literal: true

class PaymentMethod < ApplicationRecord
  include FlagShihTzu

  self.inheritance_column = :type

  has_flags 1 => :verified,
            2 => :has_issues,
            3 => :failing,
            4 => :system_issues,
            5 => :unknown_issues,
            check_for_column: false

  PROCESSING_RESULT_MAPPING = {
    ok: { verified: true, has_issues: false, failing: false, system_issues: false, unknown_issues: false },
    warning: { has_issues: true },
    error: { has_issues: true, failing: true },
    system: { system_issues: true },
    unknown: { unknown_issues: true }
  }.freeze

  acts_as_paranoid
  has_paper_trail class_name: "Version"
  has_many :versions, as: :item

  belongs_to :person

  before_save :remove_issues!, if: :issues_fixed?
  before_save :default_name, unless: :name?

  def active?
    !deleted? && !failing?
  end

  def processed(result)
    assign_attributes PROCESSING_RESULT_MAPPING[result]
  end

  def issues_fixed?
    has_issues? && information_changed?
  end

  def default_name
    self.name = I18n.t("census.payment_methods.default_names.#{self.class.to_s.demodulize.underscore}", name_info)
  end
end
