# frozen_string_literal: true

require "faker"

module Census
  module Faker
    module DocumentId
      LETTERS = "TRWAGMYFPDXBNJZSQVHLCKE"

      def self.dni
        n = ::Faker::Number.number(8)
        "#{n}#{LETTERS[n.to_i % 23].chr}"
      end

      def self.nie
        pre = [0, 1, 2].sample
        n = ::Faker::Number.number(7)
        "#{%w(X Y Z)[pre]}#{n}#{LETTERS[(pre * 10_000_000 + n.to_i) % 23].chr}"
      end

      def self.passport
        l, n = [[1, 10], [2, 6], [3, 6]].sample
        [*"A".."Z"].sample(l).join + ::Faker::Number.number(n)
      end

      def self.generate(type)
        send type
      end
    end
  end
end
