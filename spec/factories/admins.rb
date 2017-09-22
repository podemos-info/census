# frozen_string_literal: true

FactoryGirl.define do
  factory :admin do
    person
    username { Faker::Internet.user_name }
    password { Faker::Internet.password }
    roles { ["admin"] }
  end
end
