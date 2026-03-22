# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :positions, dependent: :restrict_with_error
  has_many :users, through: :positions

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
