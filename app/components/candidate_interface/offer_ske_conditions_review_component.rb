module CandidateInterface
  class OfferSkeConditionsReviewComponent < ApplicationComponent
    include SkeFormatting

    def initialize(ske_conditions:)
      @ske_conditions = ske_conditions
    end

  private

    attr_reader :ske_conditions

    def training_starts
      course.start_date
    end

    def course
      @course ||= @ske_conditions.first.offer.course_option.course
    end
  end
end
