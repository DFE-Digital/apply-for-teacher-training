module CandidateInterface
  class MidCycleContentComponent < ViewComponent::Base
    def initialize(application_form:)
      @application_form = application_form
      @completed_application_form_details = CandidateInterface::CompletedApplicationForm.new(application_form:)
    end

    attr_reader :application_form

    def application_form_presenter
      @application_form_presenter ||= CandidateInterface::ApplicationFormPresenter.new(application_form)
    end

    def incomplete_details_message
      return if @completed_application_form_details.valid?

      link = govuk_link_to('your details', candidate_interface_details_path)
      t('mid_cycle_content_component.incomplete_details_message', link:).html_safe
    end

    def christmas_response_time_warning_text
      if christmas_applications?
        govuk_warning_text(text: t('mid_cycle_content_component.christmas_warning'))
      elsif easter_applications?
        govuk_warning_text(text: t('mid_cycle_content_component.easter_warning'))
      end
    end

    def inactive_bullet
      if christmas_or_easter_delay_applications?
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

    def easter_applications?
      @easter_applications ||= application_form.application_choices.awaiting_provider_decision.any? do |application_choice|
        CandidateInterface::HolidayResponseTimeIndicator.new(application_choice:).easter_response_time_delay_possible?
      end
    end

    def christmas_or_easter_delay_applications?
      christmas_applications? || easter_applications?
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
