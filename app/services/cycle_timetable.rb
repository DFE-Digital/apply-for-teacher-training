class CycleTimetable
  # These dates are configuration for when the previous cycle ends and the next cycle starts

  def self.real_next_year
    real_current_year + 1
  end

  def self.real_current_year
    CYCLE_DATES.keys.detect do |year|
      return year if last_recruitment_cycle_year?(year)

      Time.zone.now.between?(CYCLE_DATES[year][:find_opens], CYCLE_DATES[year + 1][:find_opens])
    end
  end

  def self.current_year(now = Time.zone.now)
    if ActiveRecord::Base.connected? && current_cycle_schedule.in?(%i[today_is_after_find_opens today_is_after_apply_opens])
      now += 1.year
    end

    CYCLE_DATES.keys.detect do |year|
      return year if last_recruitment_cycle_year?(year)

      start = CYCLE_DATES[year][:find_opens]
      ending = CYCLE_DATES[year + 1][:find_opens]

      now.between?(start, ending)
    end
  end

  def self.next_year
    current_year + 1
  end

  def self.previous_year
    current_year - 1
  end

  def self.current_date
    now = Time.zone.now
    now.change(year: current_year) unless current_cycle_schedule == :real
    now
  end

  def self.show_apply_deadline_banner?(application_form)
    current_date.between?(date(:show_deadline_banner), date(:apply_deadline)) &&
      !application_form.successful?
  end

  def self.between_apply_deadline_and_find_closes?
    current_date.between?(CycleTimetable.apply_deadline, CycleTimetable.find_closes)
  end

  def self.between_reject_by_default_and_find_reopens?
    current_date.between?(CycleTimetable.reject_by_default, CycleTimetable.find_reopens)
  end

  def self.show_non_working_days_banner?
    show_christmas_non_working_days_banner? || show_easter_non_working_days_banner?
  end

  # Inclusive of the start and end dates
  def self.show_christmas_non_working_days_banner?
    if holidays[:christmas].present?
      current_date.between?(
        20.business_days.after(apply_opens).end_of_day,
        holidays[:christmas].last.end_of_day,
      )
    end
  end

  # Inclusive of the start and end dates
  def self.show_easter_non_working_days_banner?
    if holidays[:easter].present?
      current_date.between?(
        10.business_days.before(holidays[:easter].first).end_of_day,
        holidays[:easter].last.end_of_day,
      )
    end
  end

  def self.apply_deadline(year = current_year)
    date(:apply_deadline, year)
  end

  def self.next_apply_deadline
    deadlines = [
      date(:apply_deadline),
      date(:apply_deadline, next_year),
    ]
    deadlines.find { |deadline| deadline > current_date }
  end

  def self.reject_by_default(year = current_year)
    date(:reject_by_default, year)
  end

  def self.cancel_unsubmitted_applications?
    current_date.to_date == apply_deadline.to_date
  end

  def self.find_closes(year = current_year)
    date(:find_closes, year)
  end

  def self.find_opens(year = current_year)
    date(:find_opens, year)
  end

  def self.show_summer_recruitment_banner(year = current_year)
    date(:show_summer_recruitment_banner, year)
  end

  def self.find_reopens(year = next_year)
    date(:find_opens, year)
  end

  def self.find_down?
    current_date.between?(find_closes, find_reopens)
  end

  def self.days_until_find_reopens
    (find_reopens.to_date - Time.zone.today).to_i
  end

  def self.apply_opens(year = current_year)
    date(:apply_opens, year)
  end

  def self.apply_reopens(year = next_year)
    date(:apply_opens, year)
  end

  def self.holidays(year = current_year)
    # do not support the cycle switcher via #date as:
    #
    # a) fake schedules do not deal with timespans long enough for holidays
    # b) looking up SiteSetting.cycle_schedule requires a database, which we
    # don’t want (or necessarily have, in builds) at boot time when the
    # business_time initializer calls this code
    real_schedule_for(year).fetch(:holidays)
  end

  def self.apply_deadline_first_reminder
    # For 2024, date confirmed is Wednesday 17 July at 6pm
    apply_deadline - 2.months
  end

  def self.apply_deadline_second_reminder
    # For 2024, date confirmed is Saturday 17 September at 6pm
    apply_deadline - 1.month
  end

  def self.between_cycles?
    current_date.before?(apply_opens) || # In the current cycle, when find is open, but apply is not
      (CYCLE_DATES[next_year].present? && # We need to evaluated the next year to compare these dates
      current_date.between?(apply_deadline, apply_reopens)) # The current cycle deadline has passed, but apply has not reopened for the next cycle
  end

  def self.date(name, year = current_year)
    schedule = if current_cycle_schedule == :real
                 real_schedule_for(year)
               else
                 fake_schedules.fetch(current_cycle_schedule).fetch(year)
               end

    schedule.fetch(name)
  end

  #
  # cycle_week methods
  #

  def self.current_cycle_week(time = Time.zone.now)
    weeks = (time.to_date - find_opens(current_year(time)).beginning_of_week.to_date).to_i / 7
    (weeks % 52).succ
  end

  def self.cycle_week_date_range(cycle_week, time = Time.zone.now)
    year = current_year(time)
    cycle_week %= 52
    cycle_week -= 1

    start_of_week = find_opens(year) + cycle_week.weeks
    start_of_week.all_week
  end

  def self.start_of_cycle_week(...)
    cycle_week_date_range(...).first
  end

  #
  # cycle_schedule methods
  #

  def self.current_cycle_schedule
    # Make sure this setting only has effect on non-production environments
    return :real if HostingEnvironment.production?

    SiteSetting.cycle_schedule
  end

  def self.real_schedule_for(year = current_year)
    CYCLE_DATES[year]
  end

  def self.fake_schedules
    # next and previous are the same for every fake schedule
    next_and_previous = {
      next_year => {
        find_opens: 7.days.from_now,
        apply_opens: 8.days.from_now,
        show_deadline_banner: 9.days.from_now,
        show_summer_recruitment_banner: 9.days.from_now,
        apply_deadline: 11.days.from_now,
        reject_by_default: 12.days.from_now,
        find_closes: 13.days.from_now,
      },
      previous_year => {
        find_opens: 9.days.ago,
        apply_opens: 8.days.ago,
        show_deadline_banner: 7.days.ago,
        show_summer_recruitment_banner: 7.days.ago,
        apply_deadline: 5.days.ago,
        reject_by_default: 4.days.ago,
        find_closes: 3.days.ago,
      },
    }

    {
      today_is_business_as_usual: {
        current_year => {
          find_opens: 7.days.ago,
          apply_opens: 6.days.ago,
          show_deadline_banner: 1.day.from_now,
          show_summer_recruitment_banner: 1.day.from_now,
          apply_deadline: 3.days.from_now,
          reject_by_default: 4.days.from_now,
          find_closes: 5.days.from_now,
        },
        next_year => next_and_previous[next_year],
        previous_year => next_and_previous[previous_year],
      },
      today_is_mid_cycle: {
        current_year => {
          find_opens: 7.days.ago,
          apply_opens: 6.days.ago,
          show_deadline_banner: 1.day.ago,
          show_summer_recruitment_banner: 1.day.ago,
          apply_deadline: 2.days.from_now,
          reject_by_default: 3.days.from_now,
          find_closes: 4.days.from_now,
        },
        next_year => next_and_previous[next_year],
        previous_year => next_and_previous[previous_year],
      },
      today_is_after_apply_deadline_passed: {
        current_year => {
          find_opens: 7.days.ago,
          apply_opens: 6.days.ago,
          show_deadline_banner: 4.days.ago,
          show_summer_recruitment_banner: 4.days.ago,
          apply_deadline: 3.days.ago,
          reject_by_default: 1.day.from_now,
          find_closes: 2.days.from_now,
        },
        next_year => next_and_previous[next_year],
        previous_year => next_and_previous[previous_year],
      },
      today_is_after_find_closes: {
        current_year => {
          find_opens: 7.days.ago,
          apply_opens: 6.days.ago,
          show_deadline_banner: 5.days.ago,
          show_summer_recruitment_banner: 5.days.ago,
          apply_deadline: 3.days.ago,
          reject_by_default: 2.days.ago,
          find_closes: 1.day.ago,
        },
        next_year => next_and_previous[next_year],
        previous_year => next_and_previous[previous_year],
      },
      today_is_after_find_opens: {
        current_year => {
          find_opens: 3.days.ago,
          apply_opens: 3.days.from_now,
          show_deadline_banner: 4.days.from_now,
          show_summer_recruitment_banner: 5.days.from_now,
          apply_deadline: 7.days.from_now,
          reject_by_default: 8.days.from_now,
          find_closes: 9.days.from_now,
        },
        next_year => next_and_previous[next_year],
        previous_year => next_and_previous[previous_year],
      },
      today_is_after_apply_opens: {
        current_year => {
          find_opens: 7.days.ago,
          apply_opens: 6.days.ago,
          show_deadline_banner: 1.day.ago,
          show_summer_recruitment_banner: 1.day.ago,
          apply_deadline: 2.days.from_now,
          reject_by_default: 3.days.from_now,
          find_closes: 4.days.from_now,
        },
        next_year => next_and_previous[next_year],
        previous_year => next_and_previous[previous_year],
      },
    }
  end

  def self.valid_cycle?(application_form)
    application_form.recruitment_cycle_year == current_year
  end

  def self.can_add_course_choice?(application_form)
    valid_cycle?(application_form) && currently_mid_cycle?(application_form)
  end

  def self.can_submit?(application_form)
    valid_cycle?(application_form) && !before_apply_opens?
  end

  def self.before_apply_opens?
    current_date < date(:apply_opens)
  end

  def self.before_find_reopens?
    return true if current_date.to_date <= find_reopens

    false
  end

  def self.today_is_between_apply_deadline_and_find_reopens?
    current_date.between?(apply_deadline, find_reopens)
  end

  def self.before_apply_reopens?
    current_date.to_date <= apply_reopens
  end

  def self.last_recruitment_cycle_year?(year)
    year == CYCLE_DATES.keys.last
  end

  def self.currently_mid_cycle?(_application_form)
    !current_date.between?(apply_deadline, find_reopens)
  end

  def self.apply_deadline_has_passed?(application_form)
    recruitment_cycle_year = application_form.recruitment_cycle_year

    current_date > apply_deadline(recruitment_cycle_year)
  end

  def self.need_to_send_deadline_reminder?
    current_date.to_date == apply_deadline_first_reminder.to_date || current_date.to_date == apply_deadline_second_reminder.to_date
  end

  def self.send_find_has_opened_email?
    current_date.to_date == find_opens.to_date
  end

  def self.send_new_cycle_has_started_email?
    current_date.to_date == apply_opens.to_date
  end

  def self.cycle_year_range(year = current_year)
    "#{year} to #{year + 1}"
  end

  def self.service_opens_today?(service, year: RecruitmentCycle.current_year, end_of_business_day_hour: 17, end_of_business_day_min: 0)
    service_opening_date = send("#{service}_opens", year)

    current_date.between?(
      service_opening_date,
      service_opening_date.change(hour: end_of_business_day_hour, min: end_of_business_day_min),
    )
  end

  def self.this_day_last_cycle
    days_since_cycle_started = (current_date.to_date - CycleTimetable.apply_opens.to_date).round
    last_cycle_opening_date = apply_opens(previous_year).to_date
    last_cycle_date = days_since_cycle_started.days.after(last_cycle_opening_date)
    DateTime.new(last_cycle_date.year, last_cycle_date.month, last_cycle_date.day, Time.current.hour, Time.current.min, Time.current.sec)
  end

  private_class_method :last_recruitment_cycle_year?

  # Only use this to update the holidays for the current cycle when travelling time
  def self.reset_holidays
    BusinessTime::Config.holidays.clear
    Holidays.between(Date.civil(2019, 1, 1), 2.years.from_now, :gb_eng, :observed).map do |holiday|
      BusinessTime::Config.holidays << holiday[:date]
    end

    CycleTimetable.holidays.each_value do |date_range|
      BusinessTime::Config.holidays += date_range.to_a
    end
  end
end
