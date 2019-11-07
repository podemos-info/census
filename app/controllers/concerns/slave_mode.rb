# frozen_string_literal: true

module SlaveMode
  extend ActiveSupport::Concern

  included do
    class_attribute :slave_mode_block
    before_action :check_slave_mode

    def slave_mode?
      Settings.system.slave_mode
    end

    def check_slave_mode
      instance_eval(&self.class.slave_mode_block)
    end
  end

  class_methods do
    def slave_mode_check(&block)
      self.slave_mode_block = block
    end
  end
end
