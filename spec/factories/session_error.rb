FactoryBot.define do
  factory :session_error do
    candidate { association(:candidate) }
    body { 'Error' }
  end
end
