FactoryBot.define do
  factory :find_feedback do
    find_controller { 'results' }
    path { '/results' }
    feedback { Faker::Lorem.paragraph(sentence_count: 3) }
    email_address { "#{SecureRandom.hex(5)}@example.com" }
  end
end
