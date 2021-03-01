module SupportInterface
  class ReferenceWithFeedbackComponent < ViewComponent::Base
    include ViewHelper

    delegate :feedback,
             :name,
             :email_address,
             :relationship,
             :feedback_status,
             :consent_to_be_contacted,
             to: :reference

    def initialize(reference:, reference_number:)
      @reference = reference
      @reference_number = reference_number
    end

    def rows
      [
        status_row,
        date_rows,
        name_row,
        email_address_row,
        relationship_row,
        feedback_row,
        consent_row,
        sign_in_as_referee_row,
        history_row,
        possible_actions_row,
      ].flatten.compact
    end

    def title
      "#{@reference_number.ordinalize} reference ##{reference.id} #{reference.replacement? ? '(replacement)' : nil}"
    end

  private

    def status_row
      {
        key: 'Reference status',
        value: render(TagComponent.new(text: t("support_interface.reference_status.#{feedback_status}"), type: feedback_status_colour(reference))),
      }
    end

    def date_rows
      return [] if reference.not_requested_yet?

      dates = [
        {
          key: 'Requested on',
          value: reference.requested_at&.to_s(:govuk_date_and_time),
        },
      ]

      if reference.cancelled?
        dates << {
          key: 'Cancelled on',
          value: reference.cancelled_at&.to_s(:govuk_date_and_time),
        }
      end

      if reference.cancelled_at_end_of_cycle?
        dates << {
          key: 'Cancelled at end of cycle on',
          value: reference.cancelled_at_end_of_cycle_at&.to_s(:govuk_date_and_time),
        }
      end

      if reference.feedback_requested?
        dates << {
          key: 'Chase on',
          value: reference.chase_referee_at&.to_s(:govuk_date_and_time),
        }

        dates << {
          key: 'Replace on',
          value: reference.replace_referee_at&.to_s(:govuk_date_and_time),
        }
      end

      if reference.feedback_provided?
        dates << {
          key: 'Feedback provided on',
          value: reference.feedback_provided_at&.to_s(:govuk_date_and_time),
        }
      end

      if reference.feedback_refused?
        dates << {
          key: 'Declined on',
          value: reference.feedback_refused_at&.to_s(:govuk_date_and_time),
        }
      end

      if reference.email_bounced?
        dates << {
          key: 'Email bounced on',
          value: reference.email_bounced_at&.to_s(:govuk_date_and_time),
        }
      end

      dates
    end

    def name_row
      {
        key: 'Name',
        value: name,
        action: 'name',
        change_path: support_interface_application_form_edit_reference_details_path(reference.application_form, reference),
      }
    end

    def email_address_row
      {
        key: 'Email address',
        value: email_address,
        action: 'email_address',
        change_path: support_interface_application_form_edit_reference_details_path(reference.application_form, reference),
      }
    end

    def relationship_row
      {
        key: 'Relationship to candidate',
        value: relationship,
        action: 'relationship',
        change_path: support_interface_application_form_edit_reference_details_path(reference.application_form, reference),
      }
    end

    def feedback_row
      {
        key: 'Reference',
        value: feedback,
        action: 'feedback',
        change_path: support_interface_application_form_edit_reference_feedback_path(reference.application_form, reference),
      }
    end

    def consent_row
      if feedback
        {
          key: 'Given consent for research?',
          value: consent_to_be_contacted_present,
        }
      end
    end

    def sign_in_as_referee_row
      if reference.feedback_requested? && HostingEnvironment.test_environment?
        {
          key: 'Sign in as referee',
          value: govuk_link_to('Give feedback', support_interface_impersonate_referee_and_give_reference_path(reference_id: reference.id)) +
            ' or ' +
            govuk_link_to('decline to give a reference', support_interface_impersonate_referee_and_decline_reference_path(reference_id: reference.id)),
        }
      end
    end

    def history_row
      return if reference.not_requested_yet?

      {
        key: 'Email history',
        value: govuk_link_to(
          "View email history for #{title}",
          support_interface_email_log_path(
            application_form_id: reference.application_form.id,
            mailer: 'referee_mailer',
            to: reference.email_address,
          ),
        ),
      }
    end

    def possible_actions_row
      policy = ReferenceActionsPolicy.new(reference)

      [
        {
          key: 'Can be edited?',
          value: policy.editable? ? 'Yes' : 'No',
        },
        {
          key: 'Can be destroyed?',
          value: policy.can_be_destroyed? ? 'Yes' : 'No',
        },
        {
          key: 'Can be deleted?',
          value: policy.request_can_be_deleted? ? 'Yes' : 'No',
        },
        {
          key: 'Can send reminder?',
          value: policy.can_send_reminder? ? 'Yes' : 'No',
        },
        {
          key: 'Can request?',
          value: policy.can_request? ? 'Yes' : 'No',
        },
        {
          key: 'Can send?',
          value: policy.can_send? ? 'Yes' : 'No',
        },
        {
          key: 'Can resend?',
          value: policy.can_resend? ? 'Yes' : 'No',
        },
        {
          key: 'Can retry?',
          value: policy.can_retry? ? 'Yes' : 'No',
        },
      ]
    end

    def consent_to_be_contacted_present
      return ' - ' if consent_to_be_contacted.nil?

      consent_to_be_contacted == true ? 'Yes' : 'No'
    end

    def feedback_status_colour(reference)
      case reference.feedback_status
      when 'not_requested_yet'
        :grey
      when 'feedback_requested'
        reference.feedback_overdue? ? :yellow : :purple
      when 'feedback_provided'
        :green
      when 'feedback_overdue'
        :yellow
      when 'cancelled', 'cancelled_at_end_of_cycle'
        :orange
      when 'feedback_refused', 'email_bounced'
        :red
      end
    end

    attr_reader :reference
  end
end
