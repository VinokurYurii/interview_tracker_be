# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string           not null
#  last_name              :string           not null
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :positions, dependent: :destroy
  has_many :companies, through: :positions
  has_many :resumes, dependent: :destroy
  has_many :notifications, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    %w[email first_name last_name created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[positions companies resumes]
  end

  def unread_notifications_count
    notifications.where(read_at: nil).count
  end

  validates :email, length: { maximum: 100 }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
end
