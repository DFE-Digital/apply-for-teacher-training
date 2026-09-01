FactoryBot.define do
  factory :notification do
    notification_type { 'pool_opt_in' }
    notified { create(:application_form) }
  end
end
