# frozen_string_literal: true

FactoryBot.define do
  factory :interview_stage do
    stage_type { 'technical' }
    status { 'planned' }
    scheduled_at { nil }
    calendar_link { nil }
    notes { nil }
    association :position
  end
end
