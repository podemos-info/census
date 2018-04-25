# frozen_string_literal: true

module Issues
  module People
    class AdminRemark < ProcedureIssue
      class << self
        def build_for(_procedure)
          new(
            role: Admin.roles[:lopd],
            level: :medium
          )
        end

        def fix_attributes
          [:comment, :fixed]
        end
      end

      store_accessor :information, :explanation
      store_accessor :fix_information, :comment
      attr_accessor :fixed

      validates :explanation, presence: true
      validates :comment, presence: true, if: :fixing
      validates :fixed, exclusion: { in: [nil] }, if: :fixing

      def detect
        !procedure.person.discarded?
      end

      def fill
        super
        self.people = [procedure.person]
      end

      def do_the_fix
        self.close_result = :not_fixed unless ActiveModel::Type::Boolean.new.cast(fixed)
      end

      def fixed_for?(issuable)
        super && fixed?
      end
    end
  end
end
