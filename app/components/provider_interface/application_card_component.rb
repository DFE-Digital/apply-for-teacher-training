module ProviderInterface
  class ApplicationCardComponent < ViewComponent::Base
    include ViewHelper

    attr_accessor :accredited_provider, :application_choice, :application_choice_path,
                  :candidate_name, :course_name_and_code, :course_provider_name, :changed_at,
                  :site_name_and_code

    def initialize(application_choice:)
      @accredited_provider = application_choice.accredited_provider
      @application_choice = application_choice
      @candidate_name = application_choice.application_form.full_name
      @course_name_and_code = application_choice.offered_course.name_and_code
      @course_provider_name = application_choice.offered_course.provider.name
      @changed_at = application_choice.updated_at.to_s(:govuk_date_and_time)
      @site_name_and_code = application_choice.site.name_and_code
    end

    def contextual_days_to_respond
      if days_left_to_respond
        return '1 day to respond' if days_left_to_respond == 1
        return 'Less than 1 day to respond' if days_left_to_respond < 1

        "#{days_left_to_respond} days to respond"
      end
    end

    def recruitment_cycle_label
      if application_choice.current_recruitment_cycle == RecruitmentCycle.current_year
        year = RecruitmentCycle.current_year
        "Current cycle (#{year - 1} to #{year})"
      elsif application_choice.current_recruitment_cycle == RecruitmentCycle.previous_year
        year = RecruitmentCycle.previous_year
        "Previous cycle (#{year - 1} to #{year})"
      else
        year = application_choice.current_recruitment_cycle
        "#{year - 1} to #{year}"
      end
    end

  private

    def days_left_to_respond
      if application_choice.respond_to?(:pg_days_left_to_respond)
        # pre-computed by sorting query
        return application_choice.pg_days_left_to_respond
      end

      if application_choice.status == 'awaiting_provider_decision'
        rbd = application_choice.reject_by_default_at
        ((rbd - Time.zone.now) / 1.day).floor if rbd && rbd > Time.zone.now
      end
    end
  end
end
