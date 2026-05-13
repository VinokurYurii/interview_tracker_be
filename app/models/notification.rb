# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id              :bigint           not null, primary key
#  body            :text             not null
#  notifiable_type :string           not null
#  read_at         :datetime
#  title           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  notifiable_id   :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_notifications_on_notifiable           (notifiable_type,notifiable_id)
#  index_notifications_on_user_id              (user_id)
#  index_notifications_on_user_id_and_read_at  (user_id,read_at)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  validates :title, presence: true
  validates :body, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
