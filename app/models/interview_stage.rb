# frozen_string_literal: true

# == Schema Information
#
# Table name: interview_stages
#
#  id            :bigint           not null, primary key
#  calendar_link :string
#  notes         :text
#  scheduled_at  :datetime
#  stage_type    :string           not null
#  status        :string           default("planned"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  position_id   :bigint           not null
#
# Indexes
#
#  index_interview_stages_on_position_id                 (position_id)
#  index_interview_stages_on_position_id_and_stage_type  (position_id,stage_type)
#
# Foreign Keys
#
#  fk_rails_...  (position_id => positions.id)
#
class InterviewStage < ApplicationRecord
  STAGE_TYPES = %w[hr screening technical live_coding system_design take_home client managerial final offer].freeze
  STATUSES = %w[planned done declined].freeze

  belongs_to :position, touch: true
  has_many :feedbacks, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  enum :stage_type, STAGE_TYPES.index_by(&:itself)
  enum :status, STATUSES.index_by(&:itself)

  def self.ransackable_attributes(auth_object = nil)
    %w[stage_type status scheduled_at notes calendar_link created_at updated_at position_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[position feedbacks]
  end

  validates :stage_type, presence: true
  validates :status, presence: true
end
