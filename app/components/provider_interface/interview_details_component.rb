module ProviderInterface
  class InterviewDetailsComponent < ViewComponent::Base
    include ViewHelper

    def initialize(interview_form, interview = nil)
      @interview_form = interview_form
      @interview = interview
    end

    def rows
      date_row = build_row('Date', @interview_form.date_and_time.to_s(:govuk_date))
      time_row = build_row('Time', @interview_form.date_and_time.to_s(:govuk_time))
      organisation_row = build_row('Organisation carrying out interview', @interview_form.provider.name)
      location_row = build_row('Address or online meeting details', @interview_form.location)
      details_row = build_row('Additional details', @interview_form.additional_details.presence || 'None')

      [date_row, time_row, organisation_row, location_row, details_row]
    end

    def build_row(key, value)
      {
        key: key,
        value: value,
        action: "Change #{key.downcase}",
        change_path: change_path,
      }
    end

    def change_path
      if @interview.present?
        edit_provider_interface_application_choice_interview_path(@interview_form.application_choice, @interview)
      else
        new_provider_interface_application_choice_interview_path(@interview_form.application_choice)
      end
    end
  end
end
