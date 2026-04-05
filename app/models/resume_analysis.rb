# frozen_string_literal: true

class ResumeAnalysis < ApplicationRecord
  STATUSES = %w[pending processing completed failed].freeze

  belongs_to :resume

  enum :status, STATUSES.index_by(&:itself)

  validates :status, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[status model tokens_used created_at updated_at resume_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[resume]
  end
end
