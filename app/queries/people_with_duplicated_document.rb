# frozen_string_literal: true

class PeopleWithDuplicatedDocument < Rectify::Query
  def self.for(document_type:, document_scope_id:, document_id:)
    new(document_type: document_type, document_scope_id: document_scope_id, document_id: document_id).query
  end

  def initialize(document_type:, document_scope_id:, document_id:)
    @document_type = document_type
    @document_scope_id = document_scope_id
    @document_id = document_id
  end

  def query
    Person.where(document_type: @document_type, document_scope_id: @document_scope_id, document_id: @document_id)
  end
end
