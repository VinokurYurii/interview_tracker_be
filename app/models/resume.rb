# frozen_string_literal: true

class Resume < ApplicationRecord
  belongs_to :user
  has_many :positions, dependent: :nullify
  has_one_attached :file

  validates :name, presence: true, uniqueness: { scope: :user_id }

  validate :acceptable_file

  def self.ransackable_attributes(auth_object = nil)
    %w[name created_at updated_at user_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user positions file_attachment file_blob]
  end

  private

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
