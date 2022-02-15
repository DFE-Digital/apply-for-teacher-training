module ProviderInterface
  class CourseSummaryComponent < ViewComponent::Base
    include QualificationValueHelper

    attr_reader :course_option, :provider_name, :course_name_and_code,
                :location_name_and_address, :study_mode, :qualification,
                :funding_type

    def initialize(course_option:)
      @course_option = course_option
      @provider_name = course_option.provider.name
      @course_name_and_code = course_option.course.name_and_code
      @location_name_and_address = course_option.site.name_and_address
      @study_mode = course_option.study_mode.humanize
      @funding_type = course_option.course.funding_type.humanize
    end

    def rows
      rows = [
        {
          key: 'Training provider',
          value: provider_name,
        },
        {
          key: 'Course',
          value: course_name_and_code,
        },
        {
          key: 'Full time or part time',
          value: study_mode,
        },
        {
          key: 'Location',
          value: location_name_and_address,
        },
        {
          key: 'Qualification',
          value: qualification_text(course_option),
        },
        {
          key: 'Funding type',
          value: funding_type,
        },
      ]
      return rows if course_option.course.accredited_provider.blank?

      rows.insert(4, accredited_body_details(course_option))
    end

  private

    def accredited_body_details(course_option)
      {
        key: 'Accredited body',
        value: course_option.course.accredited_provider.name_and_code,
      }
    end
  end
end
