FactoryBot.define do
  factory :provider_pool_action do
    application_form factory: %i[application_form]
    provider_user factory: %i[provider_user]
    recruitment_cycle_year { RecruitmentCycleTimetable.current_year }

    trait :viewed do
      status { 'viewed' }
    end
  end
end
