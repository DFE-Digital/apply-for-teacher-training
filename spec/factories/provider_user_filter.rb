FactoryBot.define do
  factory :provider_user_filter do
    provider_user { build(:provider_user) }
    path { Rails.application.routes.url_helpers.provider_interface_candidate_pool_invites_path }
  end
end
