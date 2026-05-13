# frozen_string_literal: true

# == Schema Information
#
# Table name: resume_analyses
#
#  id            :bigint           not null, primary key
#  content       :text
#  error_message :text
#  model         :string
#  status        :string           default("pending"), not null
#  tokens_used   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  resume_id     :bigint           not null
#
# Indexes
#
#  index_resume_analyses_on_resume_id  (resume_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (resume_id => resumes.id)
#
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
