FactoryBot.define do
  factory :recruitment_cycle_timetable do
    current_timetable = RecruitmentCycleTimetable.last_timetable
    recruitment_cycle_year { current_timetable.recruitment_cycle_year + 1 }

    find_opens_at { current_timetable.find_opens_at + 1.year }
    apply_opens_at { current_timetable.apply_opens_at + 1.year }
    apply_deadline_at { current_timetable.apply_deadline_at + 1.year }
    reject_by_default_at { current_timetable.reject_by_default_at + 1.year }
    decline_by_default_at { current_timetable.decline_by_default_at + 1.year }
    find_closes_at { current_timetable.find_closes_at + 1.year }
  end
end
