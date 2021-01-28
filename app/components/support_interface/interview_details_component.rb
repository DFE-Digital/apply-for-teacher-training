module SupportInterface
  class InterviewDetailsComponent < ViewComponent::Base
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
          key: 'Meeting details',
          value: interview.location,
        },
        {
          key: 'Created at',
          value: interview.created_at.to_s(:govuk_date_and_time),
        },
        {
          key: 'Updated at',
          value: interview.created_at.to_s(:govuk_date_and_time),
        },
      ]
    end

  private

    def interview_status
      interview.cancelled_at.present? ? 'Cancelled' : 'Active'
    end
  end
end
