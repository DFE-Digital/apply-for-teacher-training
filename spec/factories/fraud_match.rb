FactoryBot.define do
  factory :fraud_match do
    recruitment_cycle_year { RecruitmentCycle.current_year }
    last_name { 'Thompson' }
    date_of_birth { '1998-08-08' }
    postcode { 'W6 9BH' }
  end
end
