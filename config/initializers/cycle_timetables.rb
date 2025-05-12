CURRENT_CYCLE_DATES = {
  # Previous cycle
  2024 => {
    find_opens: Time.zone.local(2023, 10, 3, 9), # First Tuesday of October
    apply_opens: Time.zone.local(2023, 10, 10, 9), # Second Tuesday of October
    show_summer_recruitment_banner: Time.zone.local(2024, 7, 1), # 12 weeks before deadline
    show_deadline_banner: Time.zone.local(2024, 7, 1, 9), # 12 weeks before deadline
    apply_deadline: Time.zone.local(2024, 9, 17, 18),
    reject_by_default: Time.zone.local(2024, 9, 25, 23, 59, 59), # 1 week and a day after apply deadline
    find_closes: Time.zone.local(2024, 9, 30, 23, 59, 59), # The evening before the find opens in the new cycle
    holidays: {
      christmas: Date.new(2023, 12, 18)..Date.new(2024, 1, 5),
      easter: Date.new(2024, 3, 18)..Date.new(2024, 4, 1),
    },
  },
  # Current cycle
  2025 => {
    find_opens: Time.zone.local(2024, 10, 1, 9), # First Tuesday of October
    apply_opens: Time.zone.local(2024, 10, 8, 9), # Second Tuesday of October
    show_summer_recruitment_banner: Time.zone.local(2025, 7, 1), # 12 weeks before apply deadline
    show_deadline_banner: Time.zone.local(2025, 7, 1, 9), # 12 weeks before Apply deadline
    apply_deadline: Time.zone.local(2025, 9, 16, 18),
    reject_by_default: Time.zone.local(2025, 9, 24, 23, 59, 59), # 1 week and a day after apply deadline
    find_closes: Time.zone.local(2025, 9, 30, 23, 59, 59), # The evening before the find opens in the new cycle
    holidays: {
      christmas: Date.new(2024, 12, 18)..Date.new(2025, 1, 5), # TBD
      easter: Date.new(2025, 4, 7)..Date.new(2025, 4, 21), # TBD
    },
  },
  # Next cycle
  2026 => {
    find_opens: Time.zone.local(2025, 10, 1, 9), # CONFIRMED
    apply_opens: Time.zone.local(2025, 10, 8, 9), # CONFIRMED
    show_summer_recruitment_banner: Time.zone.local(2026, 7, 1), # TBD
    show_deadline_banner: Time.zone.local(2026, 7, 1, 9), # TBD
    apply_deadline: Time.zone.local(2026, 9, 16, 18), # CONFIRMED
    reject_by_default: Time.zone.local(2026, 9, 24, 23, 59, 59), # CONFIRMED
    find_closes: Time.zone.local(2026, 9, 30, 23, 59, 59), # CONFIRMED
    holidays: {
      christmas: Date.new(2025, 12, 18)..Date.new(2026, 1, 5), # TBD
      easter: Date.new(2026, 3, 23)..Date.new(2026, 4, 6), # TBD
    },
  },

}.freeze

FUTURE_TENTATIVE_DATES = {
  2027 => {
    find_opens: Time.zone.local(2026, 10, 1, 9), # TBD
    apply_opens: Time.zone.local(2026, 10, 8, 9), # TBD
    show_summer_recruitment_banner: Time.zone.local(2027, 7, 1), # TBD
    show_deadline_banner: Time.zone.local(2027, 7, 1, 9), # TBD
    apply_deadline: Time.zone.local(2027, 9, 16, 18), # TBD
    reject_by_default: Time.zone.local(2027, 9, 24, 23, 59, 59), # TBD
    find_closes: Time.zone.local(2027, 9, 30, 23, 59, 59), # TBD
    holidays: {
      christmas: Date.new(2026, 12, 18)..Date.new(2027, 1, 5), # TBD
      easter: Date.new(2027, 3, 15)..Date.new(2027, 3, 29), # TBD
    },
  },
}.freeze

OLDER_CYCLE_DATES = {
  2019 => {
    find_opens: Time.zone.local(2018, 10, 6, 9),
    apply_opens: Time.zone.local(2018, 10, 13, 9),
    apply_1_deadline: Time.zone.local(2019, 8, 24, 18),
    apply_2_deadline: Time.zone.local(2019, 9, 18, 18),
    apply_deadline: Time.zone.local(2019, 9, 18, 18),
    reject_by_default: Time.zone.local(2019, 9, 29, 23, 59, 59),
    find_closes: Time.zone.local(2019, 10, 3, 23, 59, 59),
    holidays: {},
  },
  2020 => {
    find_opens: Time.zone.local(2019, 10, 6, 9),
    apply_opens: Time.zone.local(2019, 10, 13, 9),
    show_deadline_banner: Time.zone.local(2020, 8, 1, 9),
    show_summer_recruitment_banner: Time.zone.local(2020, 7, 1, 9),
    apply_1_deadline: Time.zone.local(2020, 8, 24, 18),
    apply_2_deadline: Time.zone.local(2020, 9, 18, 18),
    apply_deadline: Time.zone.local(2020, 9, 18, 18), # Adding an 'apply_deadline' for backward compatibility.
    reject_by_default: Time.zone.local(2020, 9, 29, 23, 59, 59),
    find_closes: Time.zone.local(2020, 10, 3, 23, 59, 59),
    holidays: {},
  },
  2021 => {
    find_opens: Time.zone.local(2020, 10, 6, 9),
    apply_opens: Time.zone.local(2020, 10, 13, 9),
    show_deadline_banner: Time.zone.local(2021, 8, 1, 9),
    show_summer_recruitment_banner: Time.zone.local(2020, 7, 1, 9),
    apply_1_deadline: Time.zone.local(2021, 9, 7, 18),
    apply_2_deadline: Time.zone.local(2021, 9, 21, 18),
    apply_deadline: Time.zone.local(2021, 9, 21, 18), # Adding an 'apply_deadline' for backward compatibility.
    reject_by_default: Time.zone.local(2021, 9, 29, 23, 59, 59),
    find_closes: Time.zone.local(2021, 10, 4, 23, 59, 59),
    holidays: {
      christmas: Date.new(2020, 12, 20)..Date.new(2021, 1, 1),
      easter: Date.new(2021, 4, 2)..Date.new(2021, 4, 16),
    },
  },
  2022 => {
    find_opens: Time.zone.local(2021, 10, 5, 9),
    apply_opens: Time.zone.local(2021, 10, 12, 9),
    show_deadline_banner: Time.zone.local(2022, 8, 2, 9), # 5 weeks before Apply 1 deadline
    show_summer_recruitment_banner: Time.zone.local(2022, 7, 1), # 20 working days before reject by default date
    apply_1_deadline: Time.zone.local(2022, 9, 6, 18), # 1st Tuesday of September
    apply_2_deadline: Time.zone.local(2022, 9, 20, 18), # 2 weeks after Apply 1 deadline
    apply_deadline: Time.zone.local(2022, 9, 20, 18), # Addling an 'apply_deadline' for backward compatibility
    reject_by_default: Time.zone.local(2022, 9, 28, 23, 59, 59), # 1 week and a day after Apply 2 deadline
    find_closes: Time.zone.local(2022, 10, 3, 23, 59, 59), # The evening before the find opens in the new cycle
    holidays: {
      christmas: Date.new(2021, 12, 14)..Date.new(2022, 1, 16),
      easter: Date.new(2022, 4, 4)..Date.new(2022, 4, 18),
    },
  },
  2023 => {
    find_opens: Time.zone.local(2022, 10, 4, 9), # First Tuesday of October
    apply_opens: Time.zone.local(2022, 10, 11, 9), # Second Tuesday of October
    show_deadline_banner: Time.zone.local(2023, 8, 1, 9), # 5 weeks before Apply 1 deadline
    show_summer_recruitment_banner: Time.zone.local(2023, 7, 1), # To be defined the dates for this banner
    apply_1_deadline: Time.zone.local(2023, 9, 5, 18), # 1st Tuesday of September
    apply_2_deadline: Time.zone.local(2023, 9, 19, 18), # 2 weeks after Apply 1 deadline
    apply_deadline: Time.zone.local(2023, 9, 19, 18), # Adding an 'apply_deadline' for backward compatibility.
    reject_by_default: Time.zone.local(2023, 9, 27, 23, 59, 59), # 1 week and a day after Apply 2 deadline
    find_closes: Time.zone.local(2023, 10, 2, 23, 59, 59), # The evening before the find opens in the new cycle
    holidays: {
      christmas: Date.new(2022, 12, 19)..Date.new(2023, 1, 6),
      easter: Date.new(2023, 3, 27)..Date.new(2023, 4, 10),
    },
  },
}.freeze

CYCLE_DATES = OLDER_CYCLE_DATES.merge(CURRENT_CYCLE_DATES, FUTURE_TENTATIVE_DATES)
