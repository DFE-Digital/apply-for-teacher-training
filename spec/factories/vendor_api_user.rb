FactoryBot.define do
  factory :vendor_api_user, class: 'VendorApiUser' do
    vendor_api_token

    full_name { 'Bob' }
    email_address { 'bob@example.com' }
    vendor_user_id { '123' }
  end
end
