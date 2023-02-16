FactoryBot.define do
  factory :ske_condition, parent: :offer_condition, class: SkeCondition do
    text { nil }

    language { nil }
    length { '8' }
    reason do
      I18n.t(
        'provider_interface.offer.ske_reasons.new.different_degree',
        degree_subject: (language || 'Mathematics').capitalize,
      )
    end

    trait :language do
      language { 'French' }
    end
  end
end
