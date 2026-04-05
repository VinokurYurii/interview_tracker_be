# frozen_string_literal: true

FactoryBot.define do
  factory :resume_analysis do
    association :resume
    status { 'pending' }
  end
end
