module ProviderInterface
  class CourseDetailsComponent < ViewComponent::Base
    include ViewHelper

    FUNDING_TYPES = { apprenticeship: :apprenticeship, salary: :salaried, fee: :fee_paying }.freeze

    attr_reader :application_choice, :provider_name_and_code, :course_name_and_code,
                :cycle, :preferred_location, :study_mode

    def initialize(application_choice:)
      @application_choice = application_choice
      @provider_name_and_code = application_choice.provider.name_and_code
      @course_name_and_code = application_choice.course.name_and_code
      @cycle = application_choice.course.recruitment_cycle_year
      @preferred_location = preferred_location_text
      @study_mode = application_choice.course_option.study_mode.humanize
    end

    def preferred_location_text
      "#{application_choice.site.name_and_code}\n" \
        "#{formatted_address}"
    end

    def accredited_body
      accredited_body = @application_choice.course.accredited_provider
      accredited_body.present? ? accredited_body.name_and_code : provider_name_and_code
    end

    def funding_type
      key = @application_choice.course.funding_type.to_sym
      FUNDING_TYPES[key].to_s.humanize
    end

  private

    def formatted_address
      site = application_choice.site
      "#{site.address_line1}, " \
        "#{site.address_line2}, " \
        "#{site.address_line3}\n" \
        "#{site.postcode}"
    end
  end
end
