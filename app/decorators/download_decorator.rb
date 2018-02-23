# frozen_string_literal: true

class DownloadDecorator < ApplicationDecorator
  delegate_all

  decorates_association :person

  def name
    filename
  end

  alias to_s name
  alias listable_name name

  def filename
    object.file.file.filename
  end
end
