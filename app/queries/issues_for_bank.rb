# frozen_string_literal: true

class IssuesForBank < Rectify::Query
  def self.for(country:, bank_code:)
    new(country: country, bank_code: bank_code).query
  end

  def initialize(country:, bank_code:)
    @country = country
    @bank_code = bank_code
  end

  def query
    Issue.where(issue_type: :missing_bic)
         .where("information ->> 'country' = ?", @country)
         .where("information ->> 'bank_code' = ?", @bank_code)
  end
end
