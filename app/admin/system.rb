# frozen_string_literal: true

ActiveAdmin.register_page "System" do
  menu priority: 99, label: proc { I18n.t("active_admin.system") }

  content title: proc { I18n.t("active_admin.system") } do
  end
end
