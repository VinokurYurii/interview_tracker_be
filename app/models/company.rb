class Company < ApplicationRecord
  has_many :positions, dependent: :destroy
  has_many :users, through: :positions

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
