FactoryBot.define do
  factory :ske_condition, parent: :offer_condition, class: 'SkeCondition' do
    text { nil }

    subject { 'Mathematics' }
    subject_type { 'standard' }
    length { '8' }
    graduation_cutoff_date { 5.years.ago.iso8601 }
    status { 'unmet' }
    reason do
      I18n.t(
        'provider_interface.offer.ske_reasons.form.different_degree',
        degree_subject: (language || 'Mathematics').capitalize,
      )
    end

    trait :language do
      subject { 'French' }
      subject_type { 'language' }
    end

    trait :outdated_degree do
      reason { 'outdated_degree' }
    end
  end
end
