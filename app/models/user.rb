# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :positions, dependent: :destroy
  has_many :companies, through: :positions

  def self.ransackable_attributes(auth_object = nil)
    %w[email first_name last_name created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[positions companies]
  end

  validates :email, length: { maximum: 100 }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
end
