FactoryBot.define do
  factory :pool_dismissal, class: 'Pool::Dismissal' do
    candidate factory: %i[candidate]
    provider factory: %i[provider]
    dismissed_by factory: %i[provider_user]
  end
end

FactoryBot.define do
  factory :pool_invite, class: 'Pool::Invite' do
    candidate factory: %i[candidate]
    provider factory: %i[provider]
    invited_by factory: %i[provider_user]
    course factory: %i[course]
  end
end
