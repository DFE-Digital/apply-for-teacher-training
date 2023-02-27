FactoryBot.define do
  factory :ske_condition, parent: :offer_condition, class: 'SkeCondition' do
    text { nil }

    subject { 'Mathematics' }
    subject_type { 'standard' }
    length { '8' }
    reason { 'different_degree' }
    graduation_cutoff_date { 5.years.ago.iso8601 }
    status { 'unmet' }

    trait :language do
      subject { 'French' }
      subject_type { 'language' }
    end

    trait :outdated_degree do
      reason { 'outdated_degree' }
    end
  end
end
