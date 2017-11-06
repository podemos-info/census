# frozen_string_literal: true

class IssuesForDocument < Rectify::Query
  def self.for(document_type:, document_scope_id:, document_id:)
    new(document_type: document_type, document_scope_id: document_scope_id, document_id: document_id).query
  end

  def initialize(document_type:, document_scope_id:, document_id:)
    @document_type = document_type
    @document_scope_id = document_scope_id
    @document_id = document_id
  end

  def query
    Issue.where(issue_type: :duplicated_document)
         .where("information @> ?", { document_type: @document_type, document_scope_id: @document_scope_id, document_id: @document_id }.to_json)
  end
end
