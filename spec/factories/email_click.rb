FactoryBot.define do
  factory :email_click do
    email

    path { '/test' }
  end
end
