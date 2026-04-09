# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    sequence(:title) { |n| "Notification #{n}" }
    body { 'Notification body text' }
    association :user
    association :notifiable, factory: :position
  end
end
