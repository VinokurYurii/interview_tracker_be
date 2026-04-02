# frozen_string_literal: true

class ResumeSerializer < ActiveModel::Serializer
  attributes :id, :name, :file_url, :created_at, :updated_at

  def file_url
    return nil unless object.file.attached?

    Rails.application.routes.url_helpers.rails_blob_url(object.file, only_path: true)
  end
end
