module CandidateInterface
  class OfferReviewComponent < SummaryListComponent
    validates :course_choice, presence: true

    def initialize(course_choice:)
      @course_choice = course_choice
    end

    def rows
      [
        provider_row,
        course_row,
        location_row,
        conditions_row,
      ]
    end

  private

    attr_reader :course_choice

    def provider_row
      {
        key: 'Provider',
        value: @course_choice.offered_course.provider.name,
      }
    end

    def course_row
      {
        key: 'Course',
        value: @course_choice.offered_course.name_and_code,
      }
    end

    def location_row
      {
        key: 'Location',
        value: @course_choice.offered_option.site.name,
      }
    end

    def conditions_row
      {
        key: 'Conditions',
        value: render(OfferConditionsReviewComponent.new(conditions: @course_choice.offer['conditions'], provider: @course_choice.offered_course.provider.name)),
      }
    end
  end
end
