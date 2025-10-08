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
        find_a_candidate_state_row,
        find_a_candidate_location_preferences_row,
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
      if one_login?
        {
          key: 'Has GOV.UK One Login',
          value: "Yes (#{candidate.one_login_auth.email_address})",
          action: {
            href: edit_support_interface_one_login_auths_path(application_form),
            visually_hidden_text: 'candidate GOV.UK One Login',
          },
        }
      else
        {
          key: 'Has GOV.UK One Login',
          value: 'No',
        }
      end
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
      {
        key: 'Is this application editable',
        value: application_form.editable_extension? ? "Yes, editable until #{application_form.editable_until.to_fs(:govuk_date_and_time)}" : 'No',
        action: {
          href: support_interface_editable_extension_path(application_form),
          visually_hidden_text: 'editable until',
        },
      }
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

    def find_a_candidate_state_row
      {
        key: 'Find a Candidate opt-in status',
        value: if application_form_in_the_pool?
                 t('.findable')
               elsif application_form.published_opt_in_preferences.present?
                 t('.opted_in')
               elsif application_form.published_preferences.last&.opt_out?
                 t('.opted_out')
               else
                 t('.no_status')
               end,
      }
    end

    def find_a_candidate_location_preferences_row
      return if @application_form.published_opt_in_preferences.blank?

      location_preferences = @application_form.published_opt_in_location_preferences
      decorated_preferences = location_preferences.map { |location| LocationPreferenceDecorator.new(location) }

      value =
        govuk_list do
          decorated_preferences.map do |location|
            tag.li t('.location', radius: location.within, location: location.decorated_name)
          end.join.html_safe
        end

      {
        key: 'Find a Candidate location preferences',
        value: location_preferences.any? ? value : 'No location preferences recorded',
      }
    end

    def application_form_in_the_pool?
      CandidatePoolApplication.where(application_form_id: application_form.id).present?
    end

    attr_reader :application_form
  end
end
