module ProviderInterface
  class ReadOnlyCompletedOfferSummaryComponent < CompletedOfferSummaryComponent
    include ViewHelper

    def rows
      [
        { key: 'Training provider',
          value: course_option.provider.name_and_code },
        { key: 'Course',
          value: course_option.course.name_and_code },
        { key: 'Full time or part time',
          value: course_option.study_mode.humanize },
        { key: 'Location',
          value: course_option.site.name_and_address },
        { key: 'Accredited body',
          value: course_option.course&.accredited_provider&.name_and_code || course_option.provider.name_and_code },
      ]
    end
  end
end
