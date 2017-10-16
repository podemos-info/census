# frozen_string_literal: true

class PaymentMethod < ApplicationRecord
  include FlagShihTzu
  include AdditionalInformation

  self.inheritance_column = :type

  has_flags 1 => :verified,
            2 => :inactive,
            3 => :user_issues,
            4 => :admin_issues,
            5 => :system_issues,
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

  def processed(response_code)
    self.response_code = response_code
    assign_attributes(response_code_info[:attributes]) if response_code_info
  end

  def reprocessable?
    false
  end

  def default_name
    self.name = I18n.t("census.payment_methods.default_names.#{self.class.to_s.demodulize.underscore}", name_info)
  end

  def needs_review?(_args = {})
    admin_issues?
  end

  def status_message
    I18n.t("census.payment_methods.status_messages.#{response_code_info[:message]}") if response_code_info
  end

  def response_code_info
    @response_code_info ||= PaymentMethod.payment_processors_response_codes.dig(payment_processor, response_code) ||
                            { message: :system, attributes: { system_issues: true } }
  end

  def self.payment_processors_response_codes
    @payment_processors_response_codes ||= begin
      ret = {}
      Settings.payments.processors.each do |payment_processor, processor_info|
        ret[payment_processor] = {}
        processor_info.response_codes&.each do |message, info|
          info.codes&.each do |response_code|
            ret[payment_processor][response_code] = {
              message: message,
              attributes: Hash[
                            (info.flags || []).map { |flag| [flag, true] } +
                            (info.not_flags || []).map { |flag| [flag, false] }
                          ]
            }
          end
        end
      end
      ret.freeze
    end
  end

  def self.flags
    flag_mapping.values.flat_map(&:keys)
  end
end
