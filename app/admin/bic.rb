# frozen_string_literal: true

ActiveAdmin.register Bic do
  decorate_with BicDecorator

  menu parent: I18n.t("active_admin.payments")

  index do
    column :name_link, class: :left
    column :bic
    actions
  end

  permit_params :country, :bank_code, :bic

  form do |f|
    f.inputs do
      f.input :country, as: :string, input_html: { readonly: f.object.persisted? }
      f.input :bank_code, input_html: { readonly: f.object.persisted? }
      f.input :bic
    end

    f.actions
  end

  controller do
    def build_resource
      set_resource_ivar decorator_class.new(BicForm.from_params(permitted_params))
    end

    def create
      bic = build_resource
      Payments::SaveBic.call(form: bic, admin: current_admin) do
        on(:invalid) { render :new }
        on(:ok) { |info| redirect_to url_for(info[:bic]) }
      end
    end

    def update
      bic = build_resource
      Payments::SaveBic.call(form: bic, admin: current_admin) do
        on(:invalid) { render :edit }
        on(:ok) { |info| redirect_to url_for(info[:bic]) }
      end
    end

    def destroy
      Payments::DestroyBic.call(bic: resource, admin: current_admin) do
        on(:invalid) { flash[:alert] = t("errors.messages.record_not_destroyed") }
      end
      redirect_to bics_path
    end
  end
end
