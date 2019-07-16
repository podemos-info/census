# frozen_string_literal: true

module FastFilter
  extend ActiveSupport::Concern

  WORDS_SEPARATOR = %r{(?:[[:alnum:]]+)(?:[.\-\/@]*[[:alnum:]]+)*}.freeze

  included do
    include PgSearch::Model

    pg_search_scope :fast_filter,
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

  def calculate_fast_filter
    self.fast_filter = fast_filter_tsvector
  end

  private

  def fast_filter_tsvector
    words = {}
    fast_filter_contents.compact
                        .map { |content| split_content(content) }
                        .flatten
                        .each_with_index do |word, index|
      words[word] ||= []
      words[word] << (index + 1)
    end
    words.map { |word, indexes| "'#{word}':#{indexes.join(",")}" } .sort.join(" ")
  end

  def split_content(content)
    content.to_s.downcase.scan(WORDS_SEPARATOR).select(&:present?)
  end
end
