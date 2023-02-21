module CandidateInterface
  class SkeConditionsComponent < ViewComponent::Base
    attr_reader :ske_conditions

    def initialize(ske_conditions:)
      @ske_conditions = ske_conditions
    end

    def start_by
      training_starts - total_length
    end

    def training_starts
      course.start_date
    end

    def provider_name
      course.provider.name
    end

  private

    def course
      @course ||= @ske_conditions.first.offer.course_option.course
    end

    def total_length
      @ske_conditions.sum { |sc| sc.length.to_i }.weeks
    end
  end
end
