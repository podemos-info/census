# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  namespace :api do
    namespace :v1 do
      resources :people, only: [:create] do
        member do
          patch :change_membership_level
        end
      end

      namespace :payments do
        resources :orders, only: [:create] do
        end
      end
    end
  end

  namespace :callbacks do
    namespace :payments do
      match ":payment_processor", to: "/callbacks#payments", via: :all
    end
  end
end
