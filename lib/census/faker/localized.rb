# frozen_string_literal: true

require "faker"

module Census
  module Faker
    # A Custom Faker wrapper so we can easily generate fake data for each
    # locale in localized attributes.
    module Localized
      # Builds a Lorem Ipsum word.
      #
      # Returns a Hash with a value for each locale.
      def self.word
        localized do
          ::Faker::Lorem.word
        end
      end

      # Sets the given text as the value for each locale.
      #
      # text - The String text to set for each locale.
      #
      # Returns a Hash with a value for each locale.
      def self.literal(text)
        I18n.available_locales.inject({}) do |result, locale|
          result.update(locale => text)
        end
      end

      # nodoc
      def self.localized
        I18n.available_locales.inject({}) do |result, locale|
          text = ::Faker::Base.with_locale(locale) do
            yield
          end

          result.update(locale => text)
        end
      end

      private_class_method :localized
    end
  end
end
