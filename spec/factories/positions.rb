# frozen_string_literal: true

FactoryBot.define do
  factory :position do
    sequence(:title) { |n| "Position #{n}" }
    description { 'Job description' }
    vacancy_url { 'https://example.com/vacancy' }
    status { 'active' }
    association :user
    association :company
  end
end
