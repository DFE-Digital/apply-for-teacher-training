class CycleTimetable
  # These dates are configuration for when the previous cycle ends and the next cycle starts
  # The 2019 dates are made up so we can generate sensible test data
  CYCLE_DATES = {
    2019 => {
      find_opens: Date.new(2018, 10, 6),
      apply_opens: Date.new(2018, 10, 13),
      apply_1_deadline: Date.new(2019, 8, 24),
      apply_2_deadline: Date.new(2019, 9, 18),
      find_closes: Date.new(2019, 10, 3),
    },
    2020 => {
      find_opens: Date.new(2019, 10, 6),
      apply_opens: Date.new(2019, 10, 13),
      show_deadline_banner: Date.new(2020, 8, 1),
      apply_1_deadline: Date.new(2020, 8, 24),
      apply_2_deadline: Date.new(2020, 9, 18),
      find_closes: Date.new(2020, 10, 3),
    },
    2021 => {
      find_opens: Date.new(2020, 10, 6),
      apply_opens: Date.new(2020, 10, 13),
      show_deadline_banner: Date.new(2021, 8, 1),
      apply_1_deadline: Date.new(2021, 9, 7),
      apply_2_deadline: Date.new(2021, 9, 20),
      find_closes: Date.new(2021, 10, 3),
    },
    2022 => {
      find_opens: Date.new(2021, 10, 5),
      apply_opens: Date.new(2021, 10, 12),
    },
  }.freeze

  def self.current_year
    now = Time.zone.today

    CYCLE_DATES.keys.detect do |year|
      return year if last_recruitment_cycle_year?(year)

      now.between?(CYCLE_DATES[year][:find_opens], CYCLE_DATES[year + 1][:find_opens])
    end
  end

  def self.next_year
    current_year + 1
  end

  def self.between_cycles?(phase)
    phase == 'apply_1' ? between_cycles_apply_1? : between_cycles_apply_2?
  end

  def self.show_apply_1_deadline_banner?(application_form)
    Time.zone.now.between?(date(:show_deadline_banner), date(:apply_1_deadline).end_of_day) &&
      application_form.phase == 'apply_1' &&
      !application_form.successful?
  end

  def self.show_apply_2_deadline_banner?(application_form)
    Time.zone.now.between?(date(:show_deadline_banner), date(:apply_2_deadline).end_of_day) &&
      (application_form.phase == 'apply_2' || application_form.phase == 'apply_1' && application_form.ended_without_success?)
  end

  def self.apply_1_deadline(year = current_year)
    date(:apply_1_deadline, year)
  end

  def self.apply_2_deadline(year = current_year)
    date(:apply_2_deadline, year)
  end

  def self.find_closes(year = current_year)
    date(:find_closes, year)
  end

  def self.find_opens(year = current_year)
    date(:find_opens, year)
  end

  def self.find_reopens(year = next_year)
    date(:find_opens, year)
  end

  def self.find_down?
    Time.zone.now.between?(find_closes.end_of_day, find_reopens.beginning_of_day)
  end

  def self.apply_opens(year = current_year)
    date(:apply_opens, year)
  end

  def self.apply_reopens(year = next_year)
    date(:apply_opens, year)
  end

  def self.apply_1_deadline_first_reminder
    (apply_1_deadline - 2.months).beginning_of_week + 1.week
  end

  def self.apply_1_deadline_second_reminder
    (apply_1_deadline - 1.month).beginning_of_week + 1.week
  end

  def self.apply_2_deadline_first_reminder
    (apply_2_deadline - 2.months).beginning_of_week + 1.week
  end

  def self.apply_2_deadline_second_reminder
    (apply_2_deadline - 1.month).beginning_of_week + 1.week
  end

  def self.between_cycles_apply_1?
    Time.zone.now > apply_1_deadline.end_of_day &&
      Time.zone.now < apply_reopens.beginning_of_day
  end

  def self.between_cycles_apply_2?
    Time.zone.now > apply_2_deadline.end_of_day &&
      Time.zone.now < apply_reopens.beginning_of_day
  end

  def self.date(name, year = current_year)
    schedule = if current_cycle_schedule == :real
                 real_schedule_for(year)
               else
                 fake_schedules.fetch(current_cycle_schedule).fetch(year)
               end

    schedule.fetch(name)
  end

  def self.current_cycle_schedule
    # Make sure this setting only has effect on non-production environments
    return :real if HostingEnvironment.production?

    SiteSetting.cycle_schedule
  end

  def self.real_schedule_for(year = current_year)
    CYCLE_DATES[year]
  end

  def self.fake_schedules
    {
      today_is_mid_cycle: {
        current_year => {
          find_opens: 7.days.ago.to_date,
          apply_opens: 6.days.ago.to_date,
          show_deadline_banner: 1.day.ago.to_date,
          apply_1_deadline: 1.day.from_now.to_date,
          apply_2_deadline: 2.days.from_now.to_date,
          find_closes: 3.days.from_now.to_date,
        },
        next_year => {
          find_opens: 6.days.from_now.to_date,
          apply_opens: 7.days.from_now.to_date,
        },
      },
      today_is_after_apply_1_deadline_passed: {
        current_year => {
          find_opens: 7.days.ago.to_date,
          apply_opens: 6.days.ago.to_date,
          show_deadline_banner: 3.days.ago.to_date,
          apply_1_deadline: 1.day.ago.to_date,
          apply_2_deadline: 2.days.from_now.to_date,
          find_closes: 3.days.from_now.to_date,
        },
        next_year => {
          find_opens: 6.days.from_now.to_date,
          apply_opens: 7.days.from_now.to_date,
        },
      },

      today_is_after_full_course_deadline_passed: {
        current_year => {
          find_opens: 7.days.ago.to_date,
          apply_opens: 6.days.ago.to_date,
          show_deadline_banner: 4.days.ago.to_date,
          apply_1_deadline: 2.days.ago.to_date,
          apply_2_deadline: 1.day.from_now.to_date,
          find_closes: 2.days.from_now.to_date,
        },
      },
      today_is_after_apply_2_deadline_passed: {
        current_year => {
          find_opens: 7.days.ago.to_date,
          apply_opens: 6.days.ago.to_date,
          show_deadline_banner: 4.days.ago.to_date,
          apply_1_deadline: 3.days.ago.to_date,
          apply_2_deadline: 1.day.ago.to_date,
          find_closes: 1.day.from_now.to_date,
        },
        next_year => {
          find_opens: 6.days.from_now.to_date,
          apply_opens: 7.days.from_now.to_date,
        },
      },

      today_is_after_find_closes: {
        current_year => {
          find_opens: 7.days.ago.to_date,
          apply_opens: 6.days.ago.to_date,
          show_deadline_banner: 5.days.ago.to_date,
          apply_1_deadline: 4.days.ago.to_date,
          apply_2_deadline: 2.days.ago.to_date,
          find_closes: 1.day.ago.to_date,
        },
        next_year => {
          find_opens: 6.days.from_now.to_date,
          apply_opens: 7.days.from_now.to_date,
        },
      },

      today_is_after_find_opens: {
        current_year => {
          find_opens: 7.days.ago.to_date,
          apply_opens: 3.days.from_now.to_date,
          show_deadline_banner: 4.days.from_now.to_date,
          apply_1_deadline: 5.days.from_now.to_date,
          apply_2_deadline: 6.days.from_now.to_date,
          find_closes: 7.days.from_now.to_date,
        },
        next_year => {
          find_opens: 6.days.from_now.to_date,
          apply_opens: 7.days.from_now.to_date,
        },
      },

      today_is_after_apply_opens: {
        current_year => {
          find_opens: 8.days.ago.to_date,
          apply_opens: 7.days.ago.to_date,
          show_deadline_banner: 5.days.ago.to_date,
          apply_1_deadline: 4.days.ago.to_date,
          apply_2_deadline: 5.days.ago.to_date,
          find_closes: 4.days.ago.to_date,
        },
        next_year => {
          find_opens: 2.days.ago.to_date,
          apply_opens: 1.day.ago.to_date,
        },
      },
    }
  end

  def self.valid_cycle?(application_form)
    application_form.recruitment_cycle_year == if current_cycle_schedule == :today_is_after_apply_opens || current_cycle_schedule == :today_is_after_find_opens
                                                 current_year + 1
                                               else
                                                 current_year
                                               end
  end

  def self.can_add_course_choice?(application_form)
    valid_cycle?(application_form) &&
      (application_form.apply_1? && !Time.zone.now.between?(apply_1_deadline, find_reopens) || application_form.apply_2? && !Time.zone.now.between?(apply_2_deadline, find_reopens))
  end

  def self.can_submit?(application_form)
    valid_cycle?(application_form) && !before_apply_opens?
  end

  def self.before_apply_opens?
    Time.zone.now.to_date < date(:apply_opens)
  end

  def self.before_find_reopens?
    return true if Time.zone.now.to_date <= find_reopens.beginning_of_day

    false
  end

  def self.before_apply_reopens?
    Time.zone.now.to_date <= apply_reopens
  end

  def self.last_recruitment_cycle_year?(year)
    year == CYCLE_DATES.keys.last
  end

  def self.currently_mid_cycle?(application_form)
    if application_form.apply_1?
      Time.zone.now.between?(find_opens, apply_1_deadline)
    else
      Time.zone.now.between?(find_opens, apply_2_deadline)
    end
  end

  def self.apply_1_deadline_has_passed?(application_form)
    recruitment_cycle_year = application_form.recruitment_cycle_year

    Time.zone.now.to_date > apply_1_deadline(recruitment_cycle_year).beginning_of_day
  end

  def self.apply_2_deadline_has_passed?(application_form)
    recruitment_cycle_year = application_form.recruitment_cycle_year

    Time.zone.now.to_date > apply_2_deadline(recruitment_cycle_year).beginning_of_day
  end

  private_class_method :last_recruitment_cycle_year?

  def self.need_to_send_deadline_reminder?
    return :apply_1 if Time.zone.now.to_date == apply_1_deadline_first_reminder || Time.zone.now.to_date == apply_1_deadline_second_reminder
    return :apply_2 if Time.zone.now.to_date == apply_2_deadline_first_reminder || Time.zone.now.to_date == apply_2_deadline_second_reminder
  end

  def self.cycle_year_range(year = current_year)
    "#{year} to #{year + 1}"
  end
end
