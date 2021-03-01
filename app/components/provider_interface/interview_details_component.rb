module ProviderInterface
  class InterviewDetailsComponent < SummaryListComponent
    include ViewHelper

    def initialize(interview_form, interview = nil)
      @interview_form = interview_form
      @interview = interview
    end

    def rows
      [
        date_row,
        time_row,
        organisation_row,
        location_row,
        details_row,
      ]
    end

  private

    def date_row
      build_row(:date, @interview_form.date_and_time.to_s(:govuk_date))
    end

    def time_row
      build_row(:time, @interview_form.date_and_time.to_s(:govuk_time))
    end

    def organisation_row
      build_row(:provider_id, @interview_form.provider.name)
    end

    def location_row
      build_row(:location, @interview_form.location)
    end

    def details_row
      build_row(:additional_details, @interview_form.additional_details.presence || 'None')
    end

    def build_row(field, value)
      key = key_for_field(field)
      {
        key: key,
        value: value,
        action: key.downcase,
        change_path: change_path(field),
      }
    end

    def key_for_field(field)
      if %i[date provider_id].include?(field)
        I18n.t!("helpers.legend.provider_interface_interview_wizard.#{field}")
      else
        I18n.t!("helpers.label.provider_interface_interview_wizard.#{field}")
      end
    end

    def change_path(field)
      anchor_to = anchor_id(field)
      if @interview.present?
        edit_provider_interface_application_choice_interview_path(@interview_form.application_choice, @interview, anchor: anchor_to)
      else
        new_provider_interface_application_choice_interview_path(@interview_form.application_choice, anchor: anchor_to)
      end
    end

    def anchor_id(field)
      case field
      when :date
        'provider_interface_interview_wizard_date_3i'
      when :provider_id
        "provider-interface-interview-wizard-provider-id-#{@interview_form.provider.id}-field"
      else
        "provider-interface-interview-wizard-#{field.to_s.dasherize}-field"
      end
    end
  end
end
