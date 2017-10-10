# frozen_string_literal: true

ActiveAdmin.register Bic do
  decorate_with BicDecorator

  menu false

  permit_params :country, :bank_code, :bic

  index do
    column :name_link, class: :left
    column :bic
    actions
  end

  form do |f|
    f.inputs do
      f.input :country, as: :string
      f.input :bank_code
      f.input :bic
    end

    f.actions
  end
end
