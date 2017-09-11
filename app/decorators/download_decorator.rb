# frozen_string_literal: true

class DownloadDecorator < Draper::Decorator
  delegate_all

  decorates_association :person

  def filename
    object.file.file.filename
  end
end
