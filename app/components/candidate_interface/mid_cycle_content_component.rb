module CandidateInterface
  class MidCycleContentComponent < ViewComponent::Base
    def initialize(application_form:)
      @application_form = application_form
    end

    attr_reader :application_form

    def application_form_presenter
      @application_form_presenter ||= CandidateInterface::ApplicationFormPresenter.new(application_form)
    end

    def christmas_response_time_warning_text
      if christmas_applications?
        govuk_warning_text(text: t('mid_cycle_content_component.christmas_warning'))
      end
    end

    def inactive_bullet
      if christmas_applications?
        t('mid_cycle_content_component.inactive_with_response_time_warning_html')
      else
        t('mid_cycle_content_component.inactive_html')
      end
    end

    def christmas_applications?
      @christmas_applications ||= application_form.application_choices.awaiting_provider_decision.any? do |application_choice|
        CandidateInterface::HolidayResponseTimeIndicator.new(application_choice:).christmas_response_time_delay_possible?
      end
    end

    def max_number_of_applications
      ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS
    end

    def apply_reopens_date
      timetable.apply_reopens_at.to_fs(:month_and_year)
    end

    def next_year
      @next_year ||= RecruitmentCycleTimetable.next_year
    end

    def timetable
      @timetable ||= application_form.recruitment_cycle_timetable
    end
  end
end
