# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  
  scope :api do
    resource :person
  end
end
