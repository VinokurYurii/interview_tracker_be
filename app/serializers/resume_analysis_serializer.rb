# frozen_string_literal: true

class ResumeAnalysisSerializer < ActiveModel::Serializer
  attributes :content, :status, :updated_at
end
