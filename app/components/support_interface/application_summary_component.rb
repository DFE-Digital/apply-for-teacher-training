module SupportInterface
  class ApplicationSummaryComponent < ViewComponent::Base
    include ViewHelper
    include GeocodeHelper

    delegate :support_reference,
             :submitted_at,
             :submitted?,
             :updated_at,
             to: :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def rows
      [
        recruitment_cycle_year,
        support_reference_row,
        candidate_id_row,
        submitted_row,
        last_updated_row,
        state_row,
        previous_application_row,
        subsequent_application_row,
        ucas_match_row,
        average_distance_row,
      ].compact
    end

  private

    def recruitment_cycle_year
      {
        key: 'Recruitment cycle year',
        value: recruitment_cycle_year_with_context,
      }
    end

    def recruitment_cycle_year_with_context
      if application_form.apply_2?
        "#{application_form.recruitment_cycle_year}, apply again"
      elsif application_form.candidate_has_previously_applied?
        "#{application_form.recruitment_cycle_year}, carried over"
      else
        application_form.recruitment_cycle_year
      end
    end

    def last_updated_row
      {
        key: 'Last updated',
        value: updated_at.to_s(:govuk_date_and_time),
      }
    end

    def submitted_row
      if submitted?
        {
          key: 'Submitted',
          value: "#{submitted_at.to_s(:govuk_date_and_time)} #{eligible_support_period}".html_safe,
        }
      end
    end

    def eligible_support_period
      time_period = submitted_at.to_date.business_days_until(Time.zone.now)

      time_period <= 5 ? govuk_tag(text: 'Less than 5 days ago', colour: 'green') : govuk_tag(text: 'Over 5 days ago', colour: 'red')
    end

    def support_reference_row
      if support_reference
        {
          key: 'Support reference',
          value: support_reference,
        }
      end
    end

    def candidate_id_row
      {
        key: 'Candidate ID',
        value: application_form.candidate.id,
      }
    end

    def state_row
      {
        key: 'State',
        value: formatted_status,
      }
    end

    def ucas_match_row
      value = if ucas_match
                govuk_link_to('View matching data for this candidate', support_interface_ucas_match_path(ucas_match))
              else
                'No matching data for this candidate'
              end

      {
        key: 'UCAS matching data',
        value: value,
      }
    end

    def previous_application_row
      return unless application_form.previous_application_form

      {
        key: 'Previous application',
        value: govuk_link_to(application_form.previous_application_form.support_reference, support_interface_application_form_path(application_form.previous_application_form)),
      }
    end

    def subsequent_application_row
      return unless application_form.subsequent_application_form

      {
        key: 'Subsequent application',
        value: govuk_link_to(application_form.subsequent_application_form.support_reference, support_interface_application_form_path(application_form.subsequent_application_form)),
      }
    end

    def average_distance_row
      {
        key: 'Average distance to sites',
        value: format_average_distance(
          application_form,
          application_form.application_choices.includes(%i[course_option site accredited_provider interviews]).map(&:site),
        ),
      }
    end

    def formatted_status
      process_state = ProcessState.new(application_form).state
      name = I18n.t!("candidate_flow_application_states.#{process_state}.name")
      desc = I18n.t!("candidate_flow_application_states.#{process_state}.description")
      "<strong>#{name}</strong><br>#{desc}".html_safe
    end

    def ucas_match
      application_form.candidate.ucas_match
    end

    attr_reader :application_form
  end
end
