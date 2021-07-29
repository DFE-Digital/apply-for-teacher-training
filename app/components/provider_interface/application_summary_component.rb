module ProviderInterface
  class ApplicationSummaryComponent < ViewComponent::Base
    include ViewHelper

    delegate :support_reference,
             :submitted_at,
             to: :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def rows
      [
        submitted_row,
        recruitment_cycle_year,
        support_reference_row,
      ].compact
    end

  private

    def submitted_row
      return unless submitted_at

      {
        key: 'Submitted',
        value: submitted_at.to_s(:govuk_date_and_time),
      }
    end

    def recruitment_cycle_year
      {
        key: 'Year received',
        value: recruitment_cycle_year_name,
      }
    end

    def support_reference_row
      {
        key: 'Reference',
        value: support_reference,
      }
    end

    def recruitment_cycle_year_name
      RecruitmentCycle::CYCLES.fetch(application_form.recruitment_cycle_year.to_s)
    end

    attr_reader :application_form
  end
end
