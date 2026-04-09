# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  validates :title, presence: true
  validates :body, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
