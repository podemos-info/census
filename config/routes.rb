# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  namespace :api do
    namespace :v1 do
      resources :people
    end
  end
end
