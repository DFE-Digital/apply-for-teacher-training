module CandidateInterface
  class InterviewSummaryComponent < ApplicationComponent
    attr_reader :interview

    def initialize(interview:)
      @interview = interview
    end

    delegate :location, to: :interview

    def time
      interview.date_and_time.to_fs(:govuk_time)
    end

    def date
      interview.date_and_time.to_fs(:govuk_date)
    end

    def details
      interview.additional_details
    end
  end
end
