FactoryBot.define do
  factory :notify_send_request, class: 'SupportInterface::NotifySendRequest' do
    template_id { SecureRandom.hex }
    email_addresses { %w[user_1@exmaple.com user_2@example.com user_3@example.com] }
    support_user { create(:support_user) }
  end
end
