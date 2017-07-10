# frozen_string_literal: true

ActiveAdmin.register Person do
  decorate_with PersonDecorator

  actions :index, :show, :new, :create, :edit, :update

  permit_params [:first_name, :last_name1, :last_name2, :document_type, :document_id,
                 :born_at, :gender, :address, :postal_code, :email, :phone, :extra]

  index do
    state_column :level
    id_column
    column :full_name, sortable: :last_name1
    column :full_document
    column :scope, sortable: "scopes.name" do |person|
      person.scope.decorate.show_path(Scope.local)
    end
    column :flags do |person|
      person_flags person
    end
    actions
  end

  scope :all
  Person.aasm.states.each do |state|
    scope state.name
  end
  scope :deleted

  show do
    attributes_table do
      state_row :level
      row :id
      row :flags { |person| person_flags(person) } if person.flags.any?
      row :first_name
      row :last_name1
      row :last_name2
      row :document_type do
        person.document_type_name
      end
      row :document_id
      row :born_at
      row :gender do
        person.gender_name
      end
      row :address
      row :address_scope do
        person.address_scope.show_path
      end
      row :postal_code
      row :email
      row :phone
      row :scope do
        person.scope.show_path(Scope.local)
      end
      row :created_at
      row :updated_at
    end
    if person.procedures.any?
      panel Procedure.model_name.human(count: 2).capitalize do
        table_for person.procedures.history.decorate, i18n: Procedure do
          column :id do |procedure|
            link_to procedure.id, procedure
          end
          column :type, &:type_name
          column :result do |procedure|
            status_tag(procedure.result_name)
          end
          column :created_at
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name1
      f.input :last_name2
      f.input :document_type, as: :select, collection: PersonDecorator.document_type_options
      f.input :document_id
      f.input :born_at, as: :datepicker
      f.input :gender, as: :select, collection: PersonDecorator.gender_options
      f.input :address
      f.input :postal_code
      f.input :email
      f.input :phone
      f.input :extra, as: :text
    end

    f.actions
  end

  sidebar :versionate, partial: "layouts/version", only: :show

  member_action :history do
    @versions = resource.versions
    render "layouts/history"
  end

  controller do
    def scoped_collection
      Person.includes(:scope)
    end

    def show
      @versions = resource.versions
      @person = resource.versions[params[:version].to_i].reify.decorate if params[:version]
      show!
    end
  end
end
