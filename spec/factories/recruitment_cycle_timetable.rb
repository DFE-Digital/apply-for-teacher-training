FactoryBot.define do
  factory :recruitment_cycle_timetable do
    recruitment_cycle_year { CycleTimetable.current_year }
    find_opens { CycleTimetable.find_opens }
    apply_opens { CycleTimetable.apply_opens }
    apply_deadline { CycleTimetable.apply_deadline }
    reject_by_default { CycleTimetable.reject_by_default }
    decline_by_default { CycleTimetable.decline_by_default_date }
    find_closes { CycleTimetable.find_closes }
    christmas_holiday { CycleTimetable.holidays[:christmas] }
    easter_holiday { CycleTimetable.holidays[:easter] }
  end
end
