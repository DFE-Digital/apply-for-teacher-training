module CandidateInterface
  class ReferencesReviewComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :references, :editable, :show_history, :is_errored

    def initialize(references:, editable: true, show_history: false, is_errored: false, heading_level: 2)
      @references = references
      @editable = editable
      @show_history = show_history
      @is_errored = is_errored
      @heading_level = heading_level
    end

    def card_title(reference)
      "#{formatted_reference_type(reference)} reference from #{reference.name}"
    end

    def reference_rows(reference)
      [
        name_row(reference),
        email_row(reference),
        reference_type_row(reference),
        relationship_row(reference),
        feedback_status_row(reference),
        history_row(reference),
      ].compact
    end

    def can_send?(reference)
      ReferenceActionsPolicy.new(reference).can_send?
    end

    def can_resend?(reference)
      ReferenceActionsPolicy.new(reference).can_resend?
    end

    def can_retry?(reference)
      ReferenceActionsPolicy.new(reference).can_retry?
    end

    def editable?(reference)
      ReferenceActionsPolicy.new(reference).editable?
    end

    def request_can_be_deleted?(reference)
      ReferenceActionsPolicy.new(reference).request_can_be_deleted?
    end

    def can_send_reminder?(reference)
      ReferenceActionsPolicy.new(reference).can_send_reminder?
    end

    def ignore_editable_for
      %w[History]
    end

    def too_many_complete_references?
      references.select(&:feedback_provided?).size > ApplicationForm::MINIMUM_COMPLETE_REFERENCES
    end

    def container_class
      if too_many_complete_references?
        "govuk-inset-text app-inset-text--narrow-border app-inset-text--#{is_errored ? 'error' : 'important'}"
      end
    end

    def too_many_references_error
      return if references.blank?

      number_to_delete = references.size - ApplicationForm::MINIMUM_COMPLETE_REFERENCES
      "Delete #{number_to_delete} #{'reference'.pluralize(number_to_delete)}. You can only include 2 with your application"
    end

  private

    def formatted_reference_type(reference)
      reference.referee_type ? reference.referee_type.capitalize.dasherize : ''
    end

    def name_row(reference)
      {
        key: 'Name',
        value: reference.name,
        action: "name for #{reference.name}",
        change_path: candidate_interface_references_edit_name_path(
          reference.id, return_to: :review
        ),
      }
    end

    def email_row(reference)
      {
        key: 'Email address',
        value: reference.email_address,
        action: "email address for #{reference.name}",
        change_path: candidate_interface_references_edit_email_address_path(
          reference.id, return_to: :review
        ),
      }
    end

    def relationship_row(reference)
      {
        key: 'Relationship to referee',
        value: reference.relationship,
        action: "relationship for #{reference.name}",
        change_path: candidate_interface_references_edit_relationship_path(
          reference.id, return_to: :review
        ),
      }
    end

    def reference_type_row(reference)
      {
        key: 'Reference type',
        value: formatted_reference_type(reference),
        action: "reference type for #{reference.name}",
        change_path: candidate_interface_references_edit_type_path(
          reference.id, return_to: :review
        ),
      }
    end

    def feedback_status_row(reference)
      value = feedback_status_label(reference) + feedback_status_content(reference)

      {
        key: 'Status',
        value: value,
      }
    end

    def history_row(reference)
      return nil unless reference.requested_at && show_history

      row_attributes = {
        key: 'History',
        value: render(CandidateInterface::ReferenceHistoryComponent.new(reference)),
      }

      if can_send_reminder?(reference)
        row_attributes.merge!(
          action: t('application_form.references.send_reminder.action'),
          action_path: candidate_interface_references_new_reminder_path(reference),
        )
      end

      row_attributes
    end

    def feedback_status_label(reference)
      govuk_tag(
        text: feedback_status_text(reference),
        colour: feedback_status_colour(reference),
      )
    end

    def feedback_status_text(reference)
      if reference.feedback_overdue? && !reference.cancelled_at_end_of_cycle?
        return t('candidate_reference_status.feedback_overdue')
      end

      t("candidate_reference_status.#{reference.feedback_status}")
    end

    def feedback_status_content(reference)
      text =
        if reference.feedback_refused?
          t('application_form.references.info.declined', referee_name: reference.name)
        elsif reference.cancelled_at_end_of_cycle?
          t('application_form.references.info.cancelled_at_end_of_cycle')
        elsif reference.cancelled?
          t('application_form.references.info.cancelled')
        elsif reference.feedback_overdue?
          t('application_form.references.info.feedback_overdue')
        elsif reference.feedback_requested?
          t('application_form.references.info.feedback_requested')
        elsif reference.email_bounced?
          t('application_form.references.info.email_bounced')
        end

      return '' if text.blank?

      if text.is_a?(Array)
        text.each_with_object('') { |line, content| content.concat(tag.p(line, class: 'govuk-body govuk-!-margin-top-2')) }.html_safe
      else
        tag.p(text, class: 'govuk-body govuk-!-margin-top-2')
      end
    end

    def feedback_status_colour(reference)
      if reference.feedback_overdue? && !reference.cancelled_at_end_of_cycle?
        return t('candidate_reference_colours.feedback_overdue')
      end

      t("candidate_reference_colours.#{reference.feedback_status}")
    end
  end
end
