FactoryBot.define do
  factory :pool_dismissal, class: 'Pool::Dismissal' do
    candidate factory: %i[candidate]
    provider factory: %i[provider]
    dismissed_by factory: %i[provider_user]
  end
end
