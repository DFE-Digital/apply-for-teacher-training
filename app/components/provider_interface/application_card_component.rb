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

    def days_to_respond_text
      if (days_left_to_respond = application_choice.days_left_to_respond)
        if days_left_to_respond.zero?
          'Last day to make decision'
        else
          "#{days_until(Date.current + days_left_to_respond).capitalize} to make decision"
        end
      end
    end

    def candidate_days_to_respond_text
      if (days_left_to_respond = application_choice.days_until_decline_by_default)
        if days_left_to_respond.positive?
          "#{days_until(Date.current + days_left_to_respond).capitalize} for candidate to respond"
        else
          'Last day for candidate to respond'
        end
      end
    end

    def recruitment_cycle_text
      if application_choice.recruitment_cycle == RecruitmentCycle.current_year
        year = RecruitmentCycle.current_year
        "Current cycle (#{year - 1} to #{year})"
      elsif application_choice.recruitment_cycle == RecruitmentCycle.previous_year
        year = RecruitmentCycle.previous_year
        "Previous cycle (#{year - 1} to #{year})"
      else
        year = application_choice.recruitment_cycle
        "#{year - 1} to #{year}"
      end
    end
  end
end
