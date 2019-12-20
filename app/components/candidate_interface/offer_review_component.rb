module CandidateInterface
  class OfferReviewComponent < ActionView::Component::Base
    validates :course_choice, presence: true

    def initialize(course_choice:)
      @course_choice = course_choice
    end

    def offer_rows
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
        value: @course_choice.course.provider.name,
      }
    end

    def course_row
      {
        key: 'Course',
        value: formatted_course_name_and_code,
      }
    end

    def location_row
      {
        key: 'Location',
        value: @course_choice.course_option.site.name,
      }
    end

    def conditions_row
      {
        key: 'Conditions',
        value: render(OfferConditionsReviewComponent, conditions: @course_choice.offer['conditions'], provider: @course_choice.course.provider.name),
      }
    end

    def formatted_course_name_and_code
      "#{@course_choice.course_option.course.name} (#{@course_choice.course_option.course.code})"
    end
  end
end
