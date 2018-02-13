# frozen_string_literal: true

list_path = Rails.root.join("config", "lists")
list_path.children.each do |file|
  Settings.add_source!(file.to_s)
end
Settings.reload!
