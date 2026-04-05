# frozen_string_literal: true

class ResumeSerializer < ActiveModel::Serializer
  attributes :id, :name, :default, :file_url, :created_at, :updated_at
  has_one :resume_analysis

  def file_url
    return nil unless object.file.attached?

    Rails.application.routes.url_helpers.rails_blob_url(object.file, only_path: true)
  end
end
