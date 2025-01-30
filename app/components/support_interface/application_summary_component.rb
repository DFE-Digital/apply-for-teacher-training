module SupportInterface
  class ApplicationSummaryComponent < ViewComponent::Base
    include ViewHelper
    include GeocodeHelper

    delegate :support_reference,
             :submitted_at,
             :submitted?,
             :updated_at,
             :candidate,
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
        average_distance_row,
        editable_extension_row,
        one_login_account_row,
        unsubscribed_from_emails,
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
        value: updated_at.to_fs(:govuk_date_and_time),
      }
    end

    def submitted_row
      if submitted?
        {
          key: 'Submitted',
          value: "#{submitted_at.to_fs(:govuk_date_and_time)} #{eligible_support_period}".html_safe,
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

    def one_login_account_row
      {
        key: 'Has One Login account',
        value: one_login? ? "Yes (#{candidate.one_login_auth.email_address})" : 'No',
      }
    end

    def unsubscribed_from_emails
      {
        key: 'Subscribed to emails',
        value: subscribed_to_emails? ? 'Yes' : 'No',
        action: {
          href: support_interface_email_subscription_path(application_form),
          visually_hidden_text: 'applicant email subscription status',
        },
      }
    end

    def state_row
      {
        key: 'State',
        value: formatted_status,
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

    def editable_extension_row
      if FeatureFlag.active?(:unlock_application_for_editing)
        {
          key: 'Is this application editable',
          value: application_form.editable_extension? ? "Yes, editable until #{application_form.editable_until.to_fs(:govuk_date_and_time)}" : 'No',
          action: {
            href: support_interface_editable_extension_path(application_form),
            visually_hidden_text: 'editable until',
          },
        }
      end
    end

    def formatted_status
      candidate_flow_state = ApplicationFormStateInferrer.new(application_form).state
      name = I18n.t!("candidate_flow_application_states.#{candidate_flow_state}.name")
      desc = I18n.t!("candidate_flow_application_states.#{candidate_flow_state}.description")
      "<strong>#{name}</strong><br>#{desc}".html_safe
    end

    def one_login?
      candidate.one_login_connected?
    end

    def subscribed_to_emails?
      candidate.subscribed_to_emails?
    end

    attr_reader :application_form
  end
end
