module CandidateInterface
  class OfferReviewComponent < SummaryListComponent
    def initialize(course_choice:)
      @course_choice = course_choice
    end

    def rows
      rows = [
        provider_row,
        course_row,
        location_row,
      ]
      rows << conditions_row if @course_choice.offer.conditions.any?
      rows
    end

  private

    attr_reader :course_choice

    def provider_row
      {
        key: 'Provider',
        value: @course_choice.current_course.provider.name,
      }
    end

    def course_row
      {
        key: 'Course',
        value: course_row_value,
      }
    end

    def location_row
      {
        key: 'Location',
        value: @course_choice.current_course_option.site.name,
      }
    end

    def conditions_row
      {
        key: 'Conditions',
        value: render(OfferConditionsReviewComponent.new(conditions: @course_choice.offer.conditions.map(&:text), provider: @course_choice.current_course.provider.name)),
      }
    end

    def course_row_value
      if EndOfCycleTimetable.find_down?
        tag.p(@course_choice.current_course.name_and_code, class: 'govuk-!-margin-bottom-0') +
          tag.p(@course_choice.current_course.description, class: 'govuk-body')
      else
        govuk_link_to(
          @course_choice.current_course.name_and_code,
          @course_choice.current_course.find_url,
          target: '_blank',
          rel: 'noopener',
        ) +
          tag.p(@course_choice.current_course.description, class: 'govuk-body')
      end
    end
  end
end
