# frozen_string_literal: true

class InterviewStageSerializer < ActiveModel::Serializer
  attributes :id, :stage_type, :status, :scheduled_at, :calendar_link, :notes, :position_id

  has_many :feedbacks, serializer: FeedbackSerializer
end
