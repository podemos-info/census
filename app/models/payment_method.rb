# frozen_string_literal: true

class PaymentMethod < ApplicationRecord
  include FlagShihTzu
  include HasAdditionalInformation
  include Issuable

  self.inheritance_column = :type

  has_flags 1 => :verified,
            2 => :inactive,
            check_for_column: false

  acts_as_paranoid
  has_paper_trail class_name: "Version"
  has_many :versions, as: :item
  has_many :orders
  belongs_to :person

  before_save :default_name, unless: :name?

  def active?
    !deleted? && !inactive?
  end

  def reprocessable?
    false
  end

  def user_visible?
    true
  end

  def default_name
    self.name = I18n.t("census.payment_methods.default_names.#{self.class.to_s.demodulize.underscore}", name_info)
  end

  def self.flags
    flag_mapping.values.flat_map(&:keys)
  end
end
