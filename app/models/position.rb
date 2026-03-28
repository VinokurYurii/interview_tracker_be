# frozen_string_literal: true

class Position < ApplicationRecord
  STATUSES = %w[active rejected offer accepted].freeze

  belongs_to :user
  belongs_to :company
  has_many :interview_stages, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    %w[title status description vacancy_url created_at updated_at user_id company_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user company interview_stages]
  end

  validates :title, presence: true
  enum :status, STATUSES.index_by(&:itself)
end
