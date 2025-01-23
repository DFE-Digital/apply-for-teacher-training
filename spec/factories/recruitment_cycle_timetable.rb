FactoryBot.define do
  factory :recruitment_cycle_timetable do
    recruitment_cycle_year { 2025 }
    find_opens { Time.zone.local(2024, 10, 1, 9) }
    apply_opens { Time.zone.local(2024, 10, 8, 9) }
    apply_deadline { Time.zone.local(2025, 9, 16, 18) }
    reject_by_default { Time.zone.local(2025, 9, 24, 23, 59, 59) }
    decline_by_default { Time.zone.local(2025, 9, 29, 23, 59, 59) }
    find_closes { Time.zone.local(2025, 9, 30, 23, 59, 59) }
    christmas_holiday { (Date.new(2024, 12, 18)..Date.new(2025, 1, 5)) }
    easter_holiday { (Date.new(2025, 4, 7)..Date.new(2025, 4, 21)) }
  end

  trait :real do
    real_timetable { true }
  end

  trait :fake do
    real_timetable { false }
  end
end
