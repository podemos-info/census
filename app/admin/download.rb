# frozen_string_literal: true

ActiveAdmin.register Download do
  decorate_with DownloadDecorator

  menu parent: :people

  includes :person

  index do
    id_column
    column :filename
    column :person, class: :left
    column :expires_at
    actions defaults: true do |download|
      link_to t("census.downloads.download"), download_download_path(download), class: :member_link
    end
  end

  member_action :download do
    send_data resource.file.file.read, type: resource.content_type, disposition: "inline"
  end
end
