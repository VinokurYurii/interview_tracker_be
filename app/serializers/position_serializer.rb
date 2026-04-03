# frozen_string_literal: true

class PositionSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :vacancy_url, :status, :company_id, :user_id

  has_one :company, serializer: CompanySerializer
  has_one :resume, serializer: ResumeCompactSerializer
  has_many :interview_stages, serializer: InterviewStageSerializer
end
