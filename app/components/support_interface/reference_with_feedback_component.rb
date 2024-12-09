module SupportInterface
  class ReferenceWithFeedbackComponent < ViewComponent::Base
    include ViewHelper

    delegate :feedback,
             :name,
             :email_address,
             :relationship,
             :feedback_status,
             :consent_to_be_contacted,
             :relationship_confirmation,
             :relationship_correction,
             :referee_type,
             to: :reference

    def initialize(reference:, reference_number:, editable:)
      @reference = reference
      @reference_number = reference_number
      @ordinal = TextOrdinalizer.call(reference_number)
      @editable = editable
    end

    def rows
      [
        status_row,
        type_of_reference_row,
        name_row,
        email_address_row,
        relationship_row,
        feedback_row,
        confidentiality_row,
        date_rows,
        sign_in_as_referee_row,
        history_row,
        consent_row,

      ].flatten.compact
    end

    def title
      reference.name
    end

    def warning_text
      return unless reference&.confidential == true
      return unless reference&.feedback_provided?

      t('support_interface.confidential_warning')
    end

  private

    def status_row
      {
        key: 'Status',
        value: govuk_tag(text: t("support_interface.reference_status.#{feedback_status}"), colour: feedback_status_colour(reference)),
      }
    end

    def type_of_reference_row
      return if referee_type.nil?

      {
        key: 'Type',
        value: I18n.t("application_form.references.referee_type.#{referee_type}.label"),
      }
    end

    def selected_row
      {
        key: 'Selected?',
        value: reference.selected? ? 'Yes' : 'No',
      }
    end

    def date_rows
      return [] if reference.not_requested_yet?

      dates = [
        {
          key: 'Requested on',
          value: reference.requested_at&.to_fs(:govuk_date_and_time),
        },
      ]

      if reference.cancelled?
        dates << {
          key: 'Cancelled on',
          value: reference.cancelled_at&.to_fs(:govuk_date_and_time),
        }
      end

      if reference.cancelled_at_end_of_cycle?
        dates << {
          key: 'Cancelled at end of cycle on',
          value: reference.cancelled_at_end_of_cycle_at&.to_fs(:govuk_date_and_time),
        }
      end

      if reference.feedback_requested?
        dates << {
          key: 'Chase on',
          value: reference.chase_referee_at&.to_fs(:govuk_date_and_time),
        }

        dates << {
          key: 'Replace on',
          value: reference.replace_referee_at&.to_fs(:govuk_date_and_time),
        }
      end

      if reference.feedback_provided?
        dates << {
          key: 'Feedback provided on',
          value: reference.feedback_provided_at&.to_fs(:govuk_date_and_time),
        }
      end

      if reference.feedback_refused?
        dates << {
          key: 'Declined on',
          value: reference.feedback_refused_at&.to_fs(:govuk_date_and_time),
        }
      end

      if reference.email_bounced?
        dates << {
          key: 'Email bounced on',
          value: reference.email_bounced_at&.to_fs(:govuk_date_and_time),
        }
      end

      dates
    end

    def name_row
      row = {
        key: 'Name',
        value: name,
      }
      return row unless @editable

      row.merge(
        action: {
          href: support_interface_application_form_edit_reference_details_path(reference.application_form, reference),
        },
      )
    end

    def email_address_row
      row = {
        key: 'Email address',
        value: email_address,
      }
      return row unless @editable

      row.merge(
        action: {
          href: support_interface_application_form_edit_reference_details_path(reference.application_form, reference),
        },
      )
    end

    def relationship_row
      row = {
        key: 'How the candidate knows them and how long for',
        value: relationship_value,
      }
      return row unless @editable

      row.merge(
        action: {
          href: support_interface_application_form_edit_reference_details_path(reference.application_form, reference),
        },
      )
    end

    def relationship_value
      value = tag.p(relationship, class: 'govuk-body')
      return value unless reference.feedback_provided?

      if relationship_correction.present?
        value += tag.p("#{reference.name} said:", class: 'govuk-body')
        value += tag.p(relationship_correction, class: 'govuk-body')
      else
        value += tag.p("This was confirmed by #{reference.name}", class: 'govuk-body')
      end

      value
    end

    def feedback_row
      row = {
        key: 'Reference',
        value: (reference.feedback_provided? ? feedback : 'Not yet given'),
      }
      return row unless @editable

      row.merge(
        action: {
          text: (reference.feedback_provided? ? 'Change' : 'Add'),
          href: support_interface_application_form_edit_reference_feedback_path(reference.application_form, reference),
          visually_hidden_text: 'reference',
        },
      )
    end

    def consent_row
      return unless reference.feedback_provided?

      {
        key: 'Consent for research',
        value: consent_to_be_contacted.present? ? 'They can be contacted' : 'They have not given consent',
      }
    end

    def sign_in_as_referee_row
      if reference.feedback_requested? && HostingEnvironment.test_environment?
        {
          key: 'Sign in as referee',
          value: "#{govuk_link_to('Give feedback', support_interface_impersonate_referee_and_give_reference_path(reference_id: reference.id))} or #{govuk_link_to('decline to give a reference', support_interface_impersonate_referee_and_decline_reference_path(reference_id: reference.id))}".html_safe,
        }
      end
    end

    def confidentiality_row
      return unless reference.feedback_provided?

      {
        key: 'Can this reference be shared with the candidate?',
        value: confidentiality_value,
      }
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

    def consent_to_be_contacted_present
      return ' - ' if consent_to_be_contacted.nil?

      consent_to_be_contacted == true ? 'Yes' : 'No'
    end

    def feedback_status_colour(reference)
      case reference.feedback_status
      when 'not_requested_yet'
        'grey'
      when 'feedback_requested'
        reference.feedback_overdue? ? 'yellow' : 'purple'
      when 'feedback_provided'
        'green'
      when 'feedback_overdue'
        'yellow'
      when 'cancelled', 'cancelled_at_end_of_cycle'
        'orange'
      when 'feedback_refused', 'email_bounced'
        'red'
      end
    end

    def confidentiality_value
      t("support_interface.references.confidential_warning.#{reference.confidential}")
    end

    attr_reader :reference
  end
end
