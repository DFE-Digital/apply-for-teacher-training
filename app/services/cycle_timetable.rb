class CycleTimetable
  def self.use_database_timetables?
    current_cycle_schedule == :real && FeatureFlag.active?(:use_database_backed_real_cycle_dates)
  end

  def self.real_next_year
    real_current_year + 1
  end

  def self.real_current_year
    if use_database_timetables?
      RecruitmentCycleTimetable.real_current_year
    else
      CYCLE_DATES.keys.detect do |year|
        return year if last_recruitment_cycle_year?(year)

        Time.zone.now.between?(CYCLE_DATES[year][:find_opens], CYCLE_DATES[year + 1][:find_opens])
      end
    end
  end

  def self.current_year(now = Time.zone.now)
    if use_database_timetables?
      RecruitmentCycleTimetable.real_timetable_for_time(now).recruitment_cycle_year
    else
      if ActiveRecord::Base.connected? && current_cycle_schedule.in?(%i[today_is_after_find_opens today_is_after_apply_opens])
        now += 1.year
      end

      CYCLE_DATES.keys.detect do |year|
        return year if last_recruitment_cycle_year?(year)

        start = CYCLE_DATES[year][:find_opens]
        ending = CYCLE_DATES[year + 1][:find_opens]

        now >= start && now < ending
      end
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

  def self.between_reject_by_default_and_find_reopens?
    current_date.between?(CycleTimetable.reject_by_default, CycleTimetable.find_reopens)
  end

  def self.apply_deadline(year = current_year)
    if use_database_timetables?
      RecruitmentCycleTimetable.real_timetable_for(year).apply_deadline
    else
      date(:apply_deadline, year)
    end
  end

  def self.reject_by_default(year = current_year)
    if use_database_timetables?
      RecruitmentCycleTimetable.real_timetable_for(year).reject_by_default
    else
      date(:reject_by_default, year)
    end
  end

  def self.decline_by_default_date(year = current_year)
    if use_database_timetables?
      RecruitmentCycleTimetable.real_timetable_for(year).decline_by_default
    else
      find_closes(year) - 1.day
    end
  end

  def self.run_decline_by_default?(year = current_year)
    if use_database_timetables?
      EndOfCycle::JobsTimetable.new(
        recruitment_cycle_timetable: real_schedule_for(year),
      ).run_decline_by_default?
    else
      current_date.between?(decline_by_default_date(year), find_closes(year))
    end
  end

  def self.run_reject_by_default?(year = current_year)
    if use_database_timetables?
      EndOfCycle::JobsTimetable.new.run_reject_by_default?
    else
      current_date.between?(reject_by_default(year), reject_by_default(year) + 1.day)
    end
  end

  def self.cancel_unsubmitted_applications?
    if use_database_timetables?
      EndOfCycle::JobsTimetable.new.run_cancel_unsubmitted_applications?
    else
      current_date.to_date == apply_deadline.to_date
    end
  end

  def self.find_closes(year = current_year)
    if use_database_timetables?
      RecruitmentCycleTimetable.real_timetable_for(year).find_closes
    else
      date(:find_closes, year)
    end
  end

  def self.find_opens(year = current_year)
    if use_database_timetables?
      RecruitmentCycleTimetable.real_timetable_for(year).find_opens
    else
      date(:find_opens, year)
    end
  end

  def self.find_reopens(year = next_year)
    find_opens(year)
  end

  def self.find_down?
    current_date.between?(find_closes, find_reopens)
  end

  def self.apply_opens(year = current_year)
    if use_database_timetables?
      RecruitmentCycleTimetable.real_timetable_for(year).apply_opens
    else
      date(:apply_opens, year)
    end
  end

  def self.apply_reopens(year = next_year)
    apply_opens(year)
  end

  def self.holidays(year = current_year)
    # do not support the cycle switcher via #date as:
    #
    # a) fake schedules do not deal with timespans long enough for holidays
    # b) looking up SiteSetting.cycle_schedule requires a database, which we
    # don’t want (or necessarily have, in builds) at boot time when the
    # business_time initializer calls this code
    if use_database_timetables?
      timetable = real_schedule_for(year)
      { christmas: timetable.christmas_holiday, easter: timetable.easter_holiday }
    else
      real_schedule_for(year).fetch(:holidays)
    end
  end

  def self.between_cycles?
    if use_database_timetables?
      real_schedule_for(current_year).between_cycles?
    else
      current_date.before?(apply_opens) || # In the current cycle, when find is open, but apply is not
        current_date.between?(apply_deadline, apply_reopens) # The current cycle deadline has passed, but apply has not reopened for the next cycle
    end
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
    if use_database_timetables?
      RecruitmentCycleTimetable.real_timetable_for(year)
    else
      CYCLE_DATES[year]
    end
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
    current_date < apply_opens
  end

  def self.before_find_reopens?
    current_date.to_date <= find_reopens
  end

  def self.today_is_between_apply_deadline_and_find_reopens?
    current_date.between?(apply_deadline, find_reopens)
  end

  def self.before_apply_reopens?
    current_date.to_date <= apply_reopens
  end

  def self.last_recruitment_cycle_year?(year)
    if use_database_timetables?
      RecruitmentCycleTimetable.real_timetables.pluck(:recruitment_cycle_year).max == year
    end
    year == CYCLE_DATES.keys.last
  end

  def self.currently_mid_cycle?(_application_form)
    !current_date.between?(apply_deadline, find_reopens)
  end

  def self.apply_deadline_has_passed?(application_form)
    recruitment_cycle_year = application_form.recruitment_cycle_year

    current_date > apply_deadline(recruitment_cycle_year)
  end

  def self.cycle_year_range(year = current_year)
    "#{year} to #{year + 1}"
  end

  def self.service_opens_today?(service, year: current_year, end_of_business_day_hour: 17, end_of_business_day_min: 0)
    service_opening_date = send("#{service}_opens", year)

    current_date.between?(
      service_opening_date,
      service_opening_date.change(hour: end_of_business_day_hour, min: end_of_business_day_min),
    )
  end

  def self.this_day_last_cycle
    days_since_cycle_started = (current_date.to_date - apply_opens.to_date).round
    last_cycle_opening_date = apply_opens(previous_year).to_date
    last_cycle_date = days_since_cycle_started.days.after(last_cycle_opening_date)
    DateTime.new(last_cycle_date.year, last_cycle_date.month, last_cycle_date.day, Time.current.hour, Time.current.min, Time.current.sec)
  end

  private_class_method :last_recruitment_cycle_year?
end
