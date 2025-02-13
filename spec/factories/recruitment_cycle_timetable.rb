FactoryBot.define do
  factory :recruitment_cycle_timetable do
    recruitment_cycle_year { RecruitmentCycleTimetable }

    find_opens_at { CycleTimetable.find_opens }
    apply_opens_at { CycleTimetable.apply_opens }
    apply_deadline_at { CycleTimetable.apply_deadline }
    reject_by_default_at { CycleTimetable.reject_by_default }
    decline_by_default_at { CycleTimetable.decline_by_default_date }
    find_closes_at { CycleTimetable.find_closes }
    christmas_holiday_range { CycleTimetable.holidays[:christmas] }
    easter_holiday_range { CycleTimetable.holidays[:easter] }
  end
end
