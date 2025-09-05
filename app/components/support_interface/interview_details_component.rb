module SupportInterface
  class InterviewDetailsComponent < ApplicationComponent
    include ViewHelper

    attr_reader :interview

    def initialize(interview:)
      @interview = interview
    end

    def rows
      [
        {
          key: 'Provider',
          value: interview.provider.name,
        },
        {
          key: 'Created at',
          value: interview.created_at.to_fs(:govuk_date_and_time),
        },
        {
          key: 'Updated at',
          value: interview.created_at.to_fs(:govuk_date_and_time),
        },
      ]
    end

  private

    def interview_status
      interview.cancelled? ? 'Cancelled' : 'Active'
    end
  end
end
