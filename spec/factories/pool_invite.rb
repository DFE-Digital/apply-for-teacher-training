FactoryBot.define do
  factory :pool_invite, class: 'Pool::Invite' do
    candidate factory: %i[candidate]
    provider factory: %i[provider]
    invited_by factory: %i[provider_user]
    course factory: %i[course]
    recruitment_cycle_year { CycleTimetableHelper.current_year }

    trait :sent_to_candidate do
      sent_to_candidate_at { Time.current }
      published
    end

    trait :not_sent_to_candidate do
      sent_to_candidate_at { nil }
    end
  end
end
