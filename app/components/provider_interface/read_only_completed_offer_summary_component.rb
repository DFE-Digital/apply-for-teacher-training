module ProviderInterface
  class ReadOnlyCompletedOfferSummaryComponent < CompletedOfferSummaryComponent
    include ViewHelper

    def rows
      rows = [
        { key: 'Training provider',
          value: course_option.provider.name_and_code },
        { key: 'Course',
          value: course_option.course.name_and_code },
        { key: 'Full time or part time',
          value: course_option.study_mode.humanize },
        { key: 'Location',
          value: course_option.site.name_and_address },
      ]
      return rows if course_option.course.accredited_provider.blank?

      rows << accredited_body_details(course_option)
    end
  end
end
