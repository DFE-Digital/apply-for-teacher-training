module CandidateInterface
  module ContinuousApplications
    class InterviewSummaryComponent < ViewComponent::Base
      attr_reader :interview

      def initialize(interview:)
        @interview = interview
      end

      def time
        interview.date_and_time.to_fs(:govuk_time)
      end

      def date
        interview.date_and_time.to_fs(:govuk_date)
      end

      def details
        interview.additional_details
      end

      def location
        interview.location
      end
    end
  end
end
