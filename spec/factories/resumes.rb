# frozen_string_literal: true

FactoryBot.define do
  factory :resume do
    sequence(:name) { |n| "Resume #{n}" }
    association :user

    trait :with_file do
      after(:build) do |resume|
        resume.file.attach(
          io: StringIO.new('%PDF-1.4 fake content'),
          filename: 'test_resume.pdf',
          content_type: 'application/pdf'
        )
      end
    end
  end
end
