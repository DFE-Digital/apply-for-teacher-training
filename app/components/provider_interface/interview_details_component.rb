module ProviderInterface
  class InterviewDetailsComponent < ViewComponent::Base
    include ViewHelper

    def initialize(interview_form)
      @interview_form = interview_form
    end

    def rows
      date_row = build_row('Date', @interview_form.date_and_time.to_s(:govuk_date))
      time_row = build_row('Time', @interview_form.date_and_time.to_s(:govuk_time))
      organisation_row = build_row('Organisation carrying out interview', @interview_form.provider.name)
      location_row = build_row('Address or online meeting details', @interview_form.location)
      details_row = build_row('Additional details', @interview_form.additional_details)

      [date_row, time_row, organisation_row, location_row, details_row]
    end

    def build_row(key, value)
      {
        key: key,
        value: value,
        change_path: new_provider_interface_application_choice_interview_path(@interview_form.application_choice),
      }
    end
  end
end
