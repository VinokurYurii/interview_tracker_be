FactoryBot.define do
  factory :feedback do
    feedback_type { 'self_review' }
    content { 'Feedback content' }
    association :interview_stage
  end
end
