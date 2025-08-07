module CandidateInterface
  class HolidayResponseTimeIndicator
    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def easter_response_time_delay_possible?
      effective_date.between?(
        10.business_days.before(good_friday),
        10.business_days.after(good_friday),
      )
    end

    def christmas_response_time_delay_possible?
      effective_date.between?(
        30.business_days.before(end_of_christmas_holiday),
        end_of_christmas_holiday,
      )
    end

    def holiday_response_time_delay_possible?
      christmas_response_time_delay_possible? || easter_response_time_delay_possible?
    end

  private

    def effective_date
      @effective_date ||= application_choice.sent_to_provider_at.presence || Time.zone.now
    end

    def good_friday
      @good_friday ||= Holidays.between(Time.zone.local(year, 1, 1), Time.zone.local(year, 6, 1), :gb_eng, :observed).find do |h|
        h[:name] == 'Good Friday'
      end[:date]
    end

    def end_of_christmas_holiday
      @end_of_christmas_holiday ||= 1.business_day.after(Time.zone.local(year, 1, 1))
    end

    def year
      @year ||= application_choice.application_form.recruitment_cycle_year
    end
  end
end
