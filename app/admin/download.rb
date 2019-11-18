# frozen_string_literal: true

ActiveAdmin.register Download do
  decorate_with DownloadDecorator

  belongs_to :orders_batch, optional: true
  belongs_to :person, optional: true

  menu parent: :dashboard

  includes :person

  actions :index, :show, :destroy

  scope :kept, default: true
  scope :discarded

  index do
    column :filename, class: :left do |download|
      link_to download.filename, [download.person, download]
    end
    column :created_at
    column :expires_at
    actions defaults: true do |download|
      span link_to(t("census.downloads.recover"), recover_download_path(download), class: :member_link, method: :patch) if download.discarded?
      span link_to t("census.downloads.download"), download_download_path(download), class: :member_link
    end
  end

  action_item :download, only: :show do
    link_to t("census.downloads.download"), download_download_path(download)
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
    send_data resource.file.file.read, filename: resource.filename, type: resource.content_type, disposition: "attachment"
  end

  member_action :recover, method: :patch do
    resource.undiscard!

    redirect_back(fallback_location: downloads_path)
  end

  controller do
    def destroy
      resource.discard!

      redirect_back(fallback_location: downloads_path)
    end
  end
end
