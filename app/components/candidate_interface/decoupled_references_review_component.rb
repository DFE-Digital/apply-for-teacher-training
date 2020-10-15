module CandidateInterface
  class DecoupledReferencesReviewComponent < ViewComponent::Base
    attr_reader :references, :editable

    def initialize(references:, editable: true)
      @references = references
      @editable = editable
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
      ].compact
    end

    def can_send?(reference)
      reference.not_requested_yet? &&
        CandidateInterface::Reference::SubmitRefereeForm.new(
          submit: 'yes',
          reference_id: reference.id,
        ).valid?
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
        change_path: candidate_interface_decoupled_references_edit_name_path(
          reference.id, return_to: :review
        ),
      }
    end

    def email_row(reference)
      {
        key: 'Email address',
        value: reference.email_address,
        action: "email address for #{reference.name}",
        change_path: candidate_interface_decoupled_references_edit_email_address_path(
          reference.id, return_to: :review
        ),
      }
    end

    def relationship_row(reference)
      {
        key: 'Relationship to referee',
        value: reference.relationship,
        action: "relationship for #{reference.name}",
        change_path: candidate_interface_decoupled_references_edit_relationship_path(
          reference.id, return_to: :review
        ),
      }
    end

    def reference_type_row(reference)
      {
        key: 'Reference type',
        value: formatted_reference_type(reference),
        action: "reference type for #{reference.name}",
        change_path: candidate_interface_decoupled_references_edit_type_path(
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

    def feedback_status_label(reference)
      render(
        TagComponent.new(
          text: feedback_status_text(reference),
          type: feedback_status_colour(reference),
        ),
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
          t('application_form.referees.info.declined', referee_name: reference.name)
        elsif reference.cancelled_at_end_of_cycle?
          t('application_form.referees.info.cancelled_at_end_of_cycle')
        elsif reference.cancelled?
          t('application_form.referees.info.cancelled')
        elsif reference.feedback_overdue?
          t('application_form.referees.info.feedback_overdue')
        elsif reference.feedback_requested?
          t('application_form.referees.info.feedback_requested')
        elsif reference.email_bounced?
          t('application_form.referees.info.email_bounced')
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
