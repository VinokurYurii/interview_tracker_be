# frozen_string_literal: true

# == Schema Information
#
# Table name: feedbacks
#
#  id                 :bigint           not null, primary key
#  content            :text             not null
#  feedback_type      :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  interview_stage_id :bigint           not null
#
# Indexes
#
#  index_feedbacks_on_interview_stage_id                    (interview_stage_id)
#  index_feedbacks_on_interview_stage_id_and_feedback_type  (interview_stage_id,feedback_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (interview_stage_id => interview_stages.id)
#
class Feedback < ApplicationRecord
  FEEDBACK_TYPES = %w[self_review company].freeze

  belongs_to :interview_stage, touch: true

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
