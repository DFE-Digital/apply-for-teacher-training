FactoryBot.define do
  factory :candidate do
    title { 'Mr' }
    first_name { 'John' }
    surname  { 'Doe' }
    gender { Candidate.genders['male'] }
    date_of_birth { 20.years.ago.to_date }
    email { 'johndoe@example.com' }
    password { 'testing123' }
    password_confirmation { 'testing123' }
  end
end
