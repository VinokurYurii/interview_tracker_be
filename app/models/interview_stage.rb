# frozen_string_literal: true

class InterviewStage < ApplicationRecord
  STAGE_TYPES = %w[hr screening technical live_coding system_design take_home client managerial final offer].freeze
  STATUSES = %w[planned done declined].freeze

  belongs_to :position
  has_many :feedbacks, dependent: :destroy

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
