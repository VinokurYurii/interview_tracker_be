# frozen_string_literal: true

class Position < ApplicationRecord
  STATUSES = %w[active rejected offer accepted].freeze

  belongs_to :user
  belongs_to :company
  has_many :interview_stages, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :vacancy_url, presence: true
  enum :status, STATUSES.index_by(&:itself)
end
