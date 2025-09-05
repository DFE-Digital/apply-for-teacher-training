# NOTE: This component is used by both provider and support UIs
module RestructuredWorkHistory
  class WorkBreakComponent < ApplicationComponent
    include ViewHelper

    def initialize(work_break:, editable: true, return_to_application_review: false, deletable: true)
      @work_break = work_break
      @editable = editable
      @return_to_application_review = return_to_application_review
      @deletable = deletable
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end

    def deletable?
      @editable && @deletable
    end

  private

    attr_reader :application_form

    def formatted_start_date
      @work_break.start_date.to_fs(:short_month_and_year)
    end

    def formatted_end_date
      return 'Present' if @work_break.end_date.nil?

      @work_break.end_date.to_fs(:short_month_and_year)
    end
  end
end
