FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    site_link { 'https://example.com' }
  end
end
