# frozen_string_literal: true

Rails.application.routes.draw do
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
    :procedures, :procedures_verification_document, :procedures_membership_level_change,
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
end
