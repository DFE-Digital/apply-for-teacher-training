# NOTE: This component is used by both provider and support UIs
module RestructuredWorkHistory
  class GapComponent < ViewComponent::Base
    include ViewHelper

    def initialize(break_period:, return_to_application_review: false)
      @break_period = break_period
      @return_to_application_review = return_to_application_review
    end

    def between_formatted_dates
      "between #{@break_period.start_date.to_s(:month_and_year)} and #{@break_period.end_date.to_s(:month_and_year)}"
    end

    def add_a_reason_params
      params = { start_date: @break_period.start_date, end_date: @break_period.end_date }

      if @return_to_application_review
        params.merge(return_to_params)
      else
        params
      end
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end
  end
end
