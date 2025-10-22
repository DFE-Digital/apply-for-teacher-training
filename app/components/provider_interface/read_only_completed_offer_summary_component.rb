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
        { key: location_key,
          value: course_option.site.name_and_address("\n") },
        { key: 'Qualification',
          value: qualification_text(course_option) },
        { key: 'Funding type',
          value: course_option.course.funding_type.humanize },
      ]
      return rows if course_option.course.accredited_provider.blank?

      rows.insert(4, accredited_body_details(course_option))
    end
  end
end
