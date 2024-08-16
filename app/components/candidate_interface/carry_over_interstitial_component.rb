module CandidateInterface
  class CarryOverInterstitialComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_form:)
      @application_form = application_form
    end

    def application_form_academic_cycle
      academic_cycle_name(application_form_recruitment_cycle_year)
    end

    def next_academic_cycle
      academic_cycle_name(next_recruitment_cycle_year)
    end

    def application_choices
      CandidateInterface::SortApplicationChoices.call(
        application_choices: @application_form.application_choices
                                              .includes(:course, :site, :provider, :current_course, :current_course_option, :interviews)
                                              .includes(offer: :conditions),
      )
    end

  private

    def academic_cycle_name(year)
      "#{year} to #{year + 1}"
    end

    def application_form_recruitment_cycle_year
      @application_form.recruitment_cycle_year
    end

    def next_recruitment_cycle_year
      if Time.zone.now.after? CycleTimetable.apply_deadline
        RecruitmentCycle.next_year
      else
        RecruitmentCycle.current_year
      end
    end
  end
end
