FactoryBot.define do
  factory :pool_invite, class: 'Pool::Invite' do
    application_form factory: %i[application_form]
    candidate { application_form.candidate }
    course factory: %i[course]
    provider { course.provider }
    invited_by factory: %i[provider_user]
    recruitment_cycle_year { application_form.recruitment_cycle_year }

    trait :sent_to_candidate do
      sent_to_candidate_at { Time.current }
      published
    end

    trait :not_sent_to_candidate do
      sent_to_candidate_at { nil }
    end
  end
end
