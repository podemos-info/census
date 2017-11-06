# frozen_string_literal: true

ActiveAdmin.register Bic do
  decorate_with BicDecorator

  menu parent: I18n.t("active_admin.payments"), if: -> { controller_name == "bics" }

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

  controller do
    def build_resource
      resource = decorator_class.new(BicForm.new(permitted_params[:bic]))
      set_resource_ivar resource

      resource
    end

    def create
      bic = build_resource
      Payments::CreateBic.call(form: bic, admin: current_admin) do
        on(:invalid) { render :new }
        on(:ok) { |saved_bic| redirect_to bic_path(saved_bic) }
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
