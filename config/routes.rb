# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  namespace :api do
    namespace :v1 do
      resources :people, only: [:create] do
        member do
          patch 'change_membership_level'
        end
      end
    end
  end
end
