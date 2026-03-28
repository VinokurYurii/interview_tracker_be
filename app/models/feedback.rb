# frozen_string_literal: true

class Feedback < ApplicationRecord
  FEEDBACK_TYPES = %w[self_review company].freeze

  belongs_to :interview_stage

  enum :feedback_type, FEEDBACK_TYPES.index_by(&:itself)

  def self.ransackable_attributes(auth_object = nil)
    %w[feedback_type content created_at updated_at interview_stage_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[interview_stage]
  end

  validates :feedback_type, presence: true
  validates :content, presence: true
  validates :feedback_type, uniqueness: { scope: :interview_stage_id }
end
