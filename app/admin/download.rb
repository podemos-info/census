# frozen_string_literal: true

ActiveAdmin.register Download do
  decorate_with DownloadDecorator

  belongs_to :person

  includes :person

  actions :index, :show

  index do
    column :filename, class: :left do |download|
      link_to download.filename, [download.person, download]
    end
    column :created_at
    column :expires_at
    actions defaults: true do |download|
      link_to t("census.downloads.download"), download_person_download_path(download.person, download), class: :member_link
    end
  end

  action_item :download, only: :show do
    link_to t("census.downloads.download"), download_person_download_path(download.person, download)
  end

  show do
    attributes_table do
      row :id
      row :filename
      row :content_type
      row :person
      row :expires_at
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  member_action :download do
    send_data resource.file.file.read, type: resource.content_type, disposition: "inline"
  end
end
