# frozen_string_literal: true

class Resume < ApplicationRecord
  belongs_to :user
  has_many :positions, dependent: :nullify
  has_one :resume_analysis, dependent: :destroy
  has_one_attached :file

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validate :only_one_default_per_user

  validate :acceptable_file

  def self.ransackable_attributes(auth_object = nil)
    %w[name created_at updated_at user_id]
  end

  def analyzable?
    file.attached? && positions.joins(:interview_stages).exists?
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user positions file_attachment file_blob]
  end

  private

  def only_one_default_per_user
    return unless default?
    return unless user&.resumes&.where(default: true)&.where&.not(id: id)&.exists?

    errors.add(:default, 'resume already exists for this user')
  end

  def acceptable_file
    return unless file.attached?

    unless file.content_type == 'application/pdf'
      errors.add(:file, 'must be a PDF')
    end

    if file.byte_size > 10.megabytes
      errors.add(:file, 'must be less than 10 MB')
    end
  end
end
