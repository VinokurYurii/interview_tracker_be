# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :positions, dependent: :restrict_with_error
  has_many :users, through: :positions

  def self.ransackable_attributes(auth_object = nil)
    %w[name site_link created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[positions users]
  end

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
