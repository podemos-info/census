# frozen_string_literal: true

def random_people
  Person.where("created_at < ?", Time.zone.now).order(Arel.sql("RANDOM()"))
end

def random_procedures(type = Procedure)
  type.where("created_at < ?", Time.zone.now).order(Arel.sql("RANDOM()"))
end
