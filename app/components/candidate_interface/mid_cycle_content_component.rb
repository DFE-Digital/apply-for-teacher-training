module CandidateInterface
  class MidCycleContentComponent < ApplicationComponent
    delegate :number_of_slots_left,
             :academic_year_range_name,
             :in_progress_limit,
             :total_submitted_application_limit_reached?,
             :can_add_more_choices?,
             :cannot_submit_more_choices?,
             :unsubmitted?,
             to: :application_form

    def initialize(application_form:, with_title: true)
      @application_form = application_form
      @with_title = with_title
    end

    attr_reader :application_form, :with_title

    def application_choices
      @application_choices ||= CandidateInterface::SortApplicationChoices.call(
        application_choices: application_form.application_choices.for_sorting,
      )
    end

    def holiday_response_time_warning_text
      if christmas_applications?
        govuk_warning_text(text: t('mid_cycle_content_component.christmas_warning'))
      elsif easter_applications?
        govuk_warning_text(text: t('mid_cycle_content_component.easter_warning'))
      end
    end

    def inactive_bullet
      if christmas_or_easter_delay_applications?
        t('mid_cycle_content_component.inactive_with_response_time_warning')
      else
        t('mid_cycle_content_component.inactive')
      end
    end

    def how_to_free_up_a_slot_list
      govuk_list(
        [
          t('mid_cycle_content_component.withdrawn'),
          t('mid_cycle_content_component.rejected_by_provider'),
          t('mid_cycle_content_component.declined_offer'),
          t('mid_cycle_content_component.conditions_not_met'),
          inactive_bullet,
        ],
        type: :bullet,
      )
    end

    def no_more_slots_message
      if cannot_submit_more_choices? # eg, max in-progress reached, no drafts
        tag.p(
          t(
            'mid_cycle_content_component.in_progress_limit_reached',
            max_number_of_in_progress_slots: in_progress_limit,
          ),
          class: 'govuk-body',
        )
      else
        tag.p(
          t(
            'mid_cycle_content_component.no_more_slots_left',
            max_number_of_slots: in_progress_limit,
          ),
          class: 'govuk-body',
        )
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
      [application_form.total_application_limit, application_form.in_progress_limit].max
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
