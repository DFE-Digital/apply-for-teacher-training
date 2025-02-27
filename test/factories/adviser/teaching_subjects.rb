FactoryBot.define do
  factory :adviser_teaching_subject, class: 'Adviser::TeachingSubject' do
    sequence(:title) { |i| "Teaching Subject #{i}" }
    sequence(:external_identifier) { |i| "git-api-id-#{i}" }
    level { 'primary' }
  end
end
