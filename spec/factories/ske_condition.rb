FactoryBot.define do
  factory :ske_condition, class: 'SkeCondition' do
    offer

    subject { 'Mathematics' }
    subject_type { 'standard' }
    length { '8' }
    graduation_cutoff_date { 5.years.ago.iso8601 }
    status { 'pending' }
    reason { SkeCondition::DIFFERENT_DEGREE_REASON }

    trait :language do
      subject { 'French' }
      subject_type { 'language' }
    end

    trait :outdated_degree do
      reason { SkeCondition::OUTDATED_DEGREE_REASON }
    end
  end
end
