# frozen_string_literal: true

ActiveAdmin.register Campaign do
  decorate_with CampaignDecorator

  menu parent: I18n.t("active_admin.payments")

  actions :index, :show, :edit, :update, :destroy

  index do
    column :campaign_code
    column :description
    column :payee
    actions
  end

  permit_params :payee_id, :description

  form do |f|
    f.inputs do
      f.input :campaign_code, label: t("activerecord.attributes.campaign.campaign_code"), as: :string, input_html: { disabled: true }
      f.input :payee
      f.input :description
    end

    f.actions
  end
end
