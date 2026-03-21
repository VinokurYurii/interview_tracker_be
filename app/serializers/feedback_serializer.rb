# frozen_string_literal: true

class FeedbackSerializer < ActiveModel::Serializer
  attributes :id, :feedback_type, :content, :interview_stage_id
end
