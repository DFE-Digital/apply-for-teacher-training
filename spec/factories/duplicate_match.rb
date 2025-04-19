FactoryBot.define do
  factory :duplicate_match do
    candidates { [create(:candidate), create(:candidate)] }
    recruitment_cycle_year { CycleTimetableHelper.current_year }
    last_name { 'Thompson' }
    date_of_birth { '1998-08-08' }
    postcode { 'W6 9BH' }
  end
end
