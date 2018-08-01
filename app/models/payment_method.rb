# frozen_string_literal: true

class PaymentMethod < ApplicationRecord
  include Discard::Model
  include FlagShihTzu
  include HasAdditionalInformation
  include Issuable

  self.inheritance_column = :type

  has_flags 1 => :verified,
            2 => :inactive,
            check_for_column: false

  has_paper_trail class_name: "Version"
  has_many :versions, as: :item, dependent: :destroy, inverse_of: :item
  has_many :orders, dependent: :restrict_with_exception
  belongs_to :person

  before_save :default_name, unless: :name?

  def active?
    !discarded? && !inactive?
  end

  def reprocessable?
    false
  end

  def complete?
    true
  end

  def default_name
    self.name = I18n.t("census.payment_methods.default_names.#{self.class.to_s.demodulize.underscore}", name_info)
  end

  def self.flags
    flag_mapping.values.flat_map(&:keys)
  end
end
