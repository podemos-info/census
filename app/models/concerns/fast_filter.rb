# frozen_string_literal: true

module FastFilter
  extend ActiveSupport::Concern

  WORDS_SEPARATOR = %r{(?:[[:alnum:]]+)(?:[.\-\/@]*[[:alnum:]]+)*}.freeze

  included do
    include PgSearch::Model

    pg_search_scope :fast_filter_search,
                    using: {
                      tsearch: {
                        tsvector_column: "fast_filter",
                        prefix: true,
                        dictionary: "simple"
                      }
                    },
                    against: :fast_filter

    before_save :calculate_fast_filter
  end

  class_methods do
    def apply_fast_filter(text)
      fast_filter_search(normalize(text))
    end

    def normalize(text)
      split_content(text).join(" ")
    end

    def split_content(content)
      content = I18n.l(content) if content.is_a?(Date)

      content.downcase.scan(WORDS_SEPARATOR).select(&:present?)
    end
  end

  def calculate_fast_filter
    self.fast_filter = fast_filter_tsvector
  end

  private

  def fast_filter_tsvector
    words = {}
    fast_filter_contents.compact
                        .map { |content| self.class.split_content(content) }
                        .flatten
                        .each_with_index do |word, index|
      words[word] ||= []
      words[word] << (index + 1)
    end
    words.map { |word, indexes| "'#{word}':#{indexes.join(",")}" } .sort.join(" ")
  end
end
