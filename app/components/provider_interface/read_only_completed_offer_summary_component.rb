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
        location_row,
        accredited_body_details,
        { key: 'Qualification',
          value: qualification_text(course_option) },
        { key: 'Funding type',
          value: course_option.course.funding_type.humanize },
      ].compact_blank
    end

    def location_row
      return {} unless application_choice.different_offer? || !@school_placement_auto_selected

      {
        key: t('school_placements.location'),
        value: course_option.site.name_and_address("\n"),
      }
    end
  end
end
