# NOTE: This component is used by both provider and support UIs
module RestructuredWorkHistory
  class JobComponent < ViewComponent::Base
    include ViewHelper

    def initialize(work_experience:, editable: true, return_to_application_review: false)
      @work_experience = work_experience
      @editable = editable
      @return_to_application_review = return_to_application_review
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end

  private

    attr_reader :application_form

    def formatted_start_date
      if @work_experience.start_date_unknown
        "#{@work_experience.start_date.to_s(:short_month_and_year)} (estimate)"
      else
        @work_experience.start_date.to_s(:short_month_and_year)
      end
    end

    def formatted_end_date
      if @work_experience.currently_working
        'to Present'
      elsif @work_experience.start_date == @work_experience.end_date
        nil
      elsif @work_experience.end_date_unknown
        "to #{@work_experience.end_date.to_s(:short_month_and_year)} (estimate)"
      else
        "to #{@work_experience.end_date.to_s(:short_month_and_year)}"
      end
    end
  end
end
