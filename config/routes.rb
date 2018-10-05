# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      scope "/(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
        resources :people, only: [:create, :update, :destroy, :show] do
          resources :document_verifications, only: [:create], controller: "people/document_verifications"
          resources :membership_levels, only: [:create], controller: "people/membership_levels"
          resources :procedures, only: [:index], controller: "people/procedures"
          resources :phone_verifications, only: [:new], controller: "people/phone_verifications"
        end

        namespace :payments do
          resources :orders, only: [:create] do
            collection do
              get :total
            end
          end
          resources :payment_methods, only: [:index, :show]
        end
      end
    end
  end

  post "csp-report", to: "misc#csp_report", as: :csp_report

  namespace :callbacks do
    namespace :payments do
      match ":payment_processor", to: "/callbacks#payments", via: :all
    end
  end

  devise_for :admins, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # multiple belongs_to for activeadmin hack
  resources :versions
  [
    :admins, :people,
    :orders, :orders_batches,
    :procedures, :procedures_document_verification, :procedures_membership_level_change,
    :payment_methods, :payment_methods_direct_debit, :payment_methods_credit_card
  ].each do |resource|
    resources resource do
      resources :versions
    end
  end

  resources :orders
  [
    :people, :orders_batches
  ].each do |resource|
    resources resource do
      resources :orders
    end
  end

  get "/404" => "errors#not_found"
  get "/500" => "errors#exception"
end
