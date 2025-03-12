module ProviderInterface
  class ApplicationSummaryComponent < ViewComponent::Base
    include ViewHelper

    delegate :support_reference,
             to: :application_form

    def initialize(application_choice:)
      @application_choice = application_choice
      @application_form = application_choice.application_form
    end

    def rows
      [
        submitted_row,
        recruitment_cycle_year,
        application_number_row,
      ].compact
    end

  private

    def submitted_row
      return unless submitted_at

      {
        key: 'Submitted',
        value: submitted_at.to_fs(:govuk_date_and_time),
      }
    end

    def recruitment_cycle_year
      {
        key: 'Recruitment cycle',
        value: recruitment_cycle_year_name,
      }
    end

    def support_reference_row
      {
        key: 'Reference',
        value: support_reference,
      }
    end

    def application_number_row
      {
        key: 'Application number',
        value: application_choice.id,
      }
    end

    def submitted_at
      application_choice.sent_to_provider_at
    end

    def recruitment_cycle_year_name
      application_form.cycle_range_name_with_current_indicator
    end

    attr_reader :application_form, :application_choice
  end
end
