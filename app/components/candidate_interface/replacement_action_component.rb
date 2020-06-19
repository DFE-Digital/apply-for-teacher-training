module CandidateInterface
  class ReplacementActionComponent < ViewComponent::Base
    include ViewHelper
    validates :course_choice, presence: true

    def initialize(course_choice:)
      @course_choice = course_choice
    end

  private

    def pick_replacement_action_form
      @pick_replacement_action_form = PickReplacementActionForm.new
    end

    def pick_site_form
      PickSiteForm.new(
        application_form: @course_choice.application_form,
        provider_id: @course_choice.provider.id,
        course_id: @course_choice.course.id,
        study_mode: @course_choice.course_option.study_mode,
        course_option_id: @course_choice.course_option.id,
      )
    end

    def pluralize_provider
      'provider'.pluralize(@course_choice.application_form.unique_provider_list.count)
    end

    def course_name_and_code
      @course_choice.course.name_and_code
    end

    def provider_name
      @course_choice.provider.name
    end

    def site_name
      @course_choice.site.name
    end

    def study_mode
      @course_choice.course_option.study_mode.humanize.downcase
    end

    def other_locations_available?
      pick_site_form.available_sites.present?
    end

    def other_study_mode
      @course_choice.course_option.get_alternative_study_mode
    end
  end
end
