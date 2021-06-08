# NOTE: This component is used by both provider and support UIs
module RestructuredWorkHistory
  class WorkBreakComponent < ViewComponent::Base
    include ViewHelper

    def initialize(work_break:, editable: true)
      @work_break = work_break
      @editable = editable
    end

  private

    attr_reader :application_form

    def formatted_start_date
      @work_break.start_date.to_s(:short_month_and_year)
    end

    def formatted_end_date
      return 'Present' if @work_break.end_date.nil?

      @work_break.end_date.to_s(:short_month_and_year)
    end
  end
end
