# frozen_string_literal: true

require "faker"

module Census
  module Faker
    # A Custom Faker wrapper so we can easily generate fake data for each
    # locale in localized attributes.
    module Localized
      # Fakes a person name.
      #
      # Returns a Hash with a value for each locale.
      def self.name
        localized do
          ::Faker::Name.name
        end
      end

      # Builds a Lorem Ipsum word.
      #
      # Returns a Hash with a value for each locale.
      def self.word
        localized do
          ::Faker::Lorem.word
        end
      end

      # Builds many Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.words(*args)
        localized do
          ::Faker::Lorem.words(*args)
        end
      end

      # Builds a Lorem Ipsum character.
      #
      # Returns a Hash with a value for each locale.
      def self.character
        localized do
          ::Faker::Lorem.character
        end
      end

      # Builds many Lorem Ipsum characters. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.characters(*args)
        localized do
          ::Faker::Lorem.characters(*args)
        end
      end

      # Builds a sentence with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.sentence(*args)
        localized do
          ::Faker::Lorem.sentence(*args)
        end
      end

      # Builds many sentences with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.sentences(*args)
        localized do
          ::Faker::Lorem.sentences(*args)
        end
      end

      # Builds a paragraph with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.paragraph(*args)
        localized do
          ::Faker::Lorem.paragraph(*args)
        end
      end

      # Builds many paragraphs with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.paragraphs(*args)
        localized do
          ::Faker::Lorem.paragraphs(*args)
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
