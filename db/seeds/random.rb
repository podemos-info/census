# frozen_string_literal: true

def random_people(limit, scopes: [], include_ids: [], exclude_ids: [])
  included = Person.where(id: include_ids).to_a
  query = scopes.reduce(Person, &:send).where("created_at < ?", Time.current).where.not(id: exclude_ids + include_ids)
  included + query.order(Arel.sql("RANDOM()")).limit(limit).to_a
end

def random_procedures(type = Procedure)
  type.where("created_at < ?", Time.current).order(Arel.sql("RANDOM()"))
end
