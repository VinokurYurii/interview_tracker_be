# frozen_string_literal: true

# == Schema Information
#
# Table name: positions
#
#  id          :bigint           not null, primary key
#  description :text
#  status      :string           default("active"), not null
#  title       :string           not null
#  vacancy_url :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  company_id  :bigint           not null
#  resume_id   :bigint
#  user_id     :bigint           not null
#
# Indexes
#
#  index_positions_on_company_id  (company_id)
#  index_positions_on_resume_id   (resume_id)
#  index_positions_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (resume_id => resumes.id) ON DELETE => nullify
#  fk_rails_...  (user_id => users.id)
#
class Position < ApplicationRecord
  STATUSES = %w[active rejected offer accepted].freeze

  belongs_to :user
  belongs_to :company
  belongs_to :resume, optional: true
  has_many :interview_stages, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    %w[title status description vacancy_url created_at updated_at user_id company_id resume_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user company resume interview_stages]
  end

  validates :title, presence: true
  enum :status, STATUSES.index_by(&:itself)
end
