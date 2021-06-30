class EndOfCycleTimetable
  CURRENT_YEAR_FOR_SCHEDULE = 2021

  # These dates are configuration for when the previous cycle ends and the next cycle starts
  # The 2020 dates are made up so we can generate sensible test data
  CYCLE_DATES = {
    2020 => {
      apply_1_deadline: Date.new(2019, 8, 24),
      stop_applications_to_unavailable_course_options: Date.new(2019, 9, 7),
      apply_2_deadline: Date.new(2019, 9, 18),
      find_closes: Date.new(2019, 10, 3),
      find_reopens: Date.new(2019, 10, 6),
      apply_reopens: Date.new(2019, 10, 13),
    },
    2021 => {
      apply_1_deadline: Date.new(2020, 8, 24),
      stop_applications_to_unavailable_course_options: Date.new(2020, 9, 7),
      apply_2_deadline: Date.new(2020, 9, 18),
      find_closes: Date.new(2020, 10, 3),
      find_reopens: Date.new(2020, 10, 6),
      apply_reopens: Date.new(2020, 10, 13),
    },
  }.freeze

  def self.between_cycles?(phase)
    phase == 'apply_1' ? between_cycles_apply_1? : between_cycles_apply_2?
  end

  def self.show_apply_1_deadline_banner?
    Time.zone.now < date(:apply_1_deadline).end_of_day
  end

  def self.show_apply_2_deadline_banner?
    Time.zone.now < date(:apply_2_deadline).end_of_day
  end

  def self.stop_applications_to_unavailable_course_options?
    Time.zone.now > date(:stop_applications_to_unavailable_course_options).end_of_day &&
      Time.zone.now < date(:apply_reopens).beginning_of_day
  end

  def self.apply_1_deadline
    date(:apply_1_deadline)
  end

  def self.stop_applications_to_unavailable_course_options
    date(:stop_applications_to_unavailable_course_options)
  end

  def self.apply_2_deadline
    date(:apply_2_deadline)
  end

  def self.find_closes
    date(:find_closes)
  end

  def self.find_reopens
    date(:find_reopens)
  end

  def self.find_down?
    Time.zone.now.between?(find_closes.end_of_day, find_reopens.beginning_of_day)
  end

  def self.apply_reopens
    date(:apply_reopens)
  end

  def self.between_cycles_apply_1?
    Time.zone.now > date(:apply_1_deadline).end_of_day &&
      Time.zone.now < date(:apply_reopens).beginning_of_day
  end

  def self.between_cycles_apply_2?
    Time.zone.now > date(:apply_2_deadline).end_of_day &&
      Time.zone.now < date(:apply_reopens).beginning_of_day
  end

  def self.date(name)
    schedule = schedules.fetch(current_cycle_schedule)
    schedule.fetch(name)
  end

  def self.current_cycle_schedule
    # Make sure this setting only has effect on non-production environments
    return :real if HostingEnvironment.production?

    SiteSetting.cycle_schedule
  end

  def self.next_cycle_year
    RecruitmentCycle.current_year + 1
  end

  def self.schedules
    {
      real: CYCLE_DATES[CURRENT_YEAR_FOR_SCHEDULE],

      today_is_mid_cycle: {
        apply_1_deadline: 1.day.from_now.to_date,
        stop_applications_to_unavailable_course_options: 2.days.from_now.to_date,
        apply_2_deadline: 3.days.from_now.to_date,
        find_closes: 4.days.from_now.to_date,
        find_reopens: 5.days.from_now.to_date,
        apply_reopens: 6.days.from_now.to_date,
      },

      today_is_after_apply_1_deadline_passed: {
        apply_1_deadline: 1.day.ago.to_date,

        stop_applications_to_unavailable_course_options: 1.day.from_now.to_date,
        apply_2_deadline: 2.days.from_now.to_date,
        find_closes: 3.days.from_now.to_date,
        find_reopens: 4.days.from_now.to_date,
        apply_reopens: 5.days.from_now.to_date,
      },

      today_is_after_full_course_deadline_passed: {
        apply_1_deadline: 2.days.ago.to_date,
        stop_applications_to_unavailable_course_options: 1.day.ago.to_date,

        apply_2_deadline: 1.day.from_now.to_date,
        find_closes: 2.days.from_now.to_date,
        find_reopens: 3.days.from_now.to_date,
        apply_reopens: 4.days.from_now.to_date,
      },

      today_is_after_apply_2_deadline_passed: {
        apply_1_deadline: 3.days.ago.to_date,
        stop_applications_to_unavailable_course_options: 2.days.ago.to_date,
        apply_2_deadline: 1.day.ago.to_date,

        find_closes: 1.day.from_now.to_date,
        find_reopens: 2.days.from_now.to_date,
        apply_reopens: 3.days.from_now.to_date,
      },

      today_is_after_find_closes: {
        apply_1_deadline: 4.days.ago.to_date,
        stop_applications_to_unavailable_course_options: 3.days.ago.to_date,
        apply_2_deadline: 2.days.ago.to_date,
        find_closes: 1.day.ago.to_date,

        find_reopens: 1.day.from_now.to_date,
        apply_reopens: 2.days.from_now.to_date,
      },

      today_is_after_find_reopens: {
        apply_1_deadline: 5.days.ago.to_date,
        stop_applications_to_unavailable_course_options: 4.days.ago.to_date,
        apply_2_deadline: 3.days.ago.to_date,
        find_closes: 2.days.ago.to_date,
        find_reopens: 1.day.ago.to_date,

        apply_reopens: 1.day.from_now.to_date,
      },

      today_is_after_apply_reopens: {
        apply_1_deadline: 6.days.ago.to_date,
        stop_applications_to_unavailable_course_options: 5.days.ago.to_date,
        apply_2_deadline: 4.days.ago.to_date,
        find_closes: 3.days.ago.to_date,
        find_reopens: 2.days.ago.to_date,
        apply_reopens: 1.day.ago.to_date,
      },
    }
  end

  def self.current_cycle?(application_form)
    application_form.recruitment_cycle_year == RecruitmentCycle.current_year
  end

  def self.can_add_course_choice?(application_form)
    return true if Time.zone.now.to_date >= find_reopens && !application_form.must_be_carried_over?
    return true if Time.zone.now.to_date <= apply_1_deadline && application_form.apply_1?
    return true if Time.zone.now.to_date <= apply_2_deadline && application_form.apply_2?

    false
  end

  def self.can_submit?(application_form)
    RecruitmentCycle.current_year == application_form.recruitment_cycle_year
  end

  def self.before_find_reopens?
    return true if Time.zone.now.to_date <= find_reopens.beginning_of_day

    false
  end

  def self.before_apply_reopens?
    return true if Time.zone.now.to_date <= apply_reopens.beginning_of_day

    false
  end
end
