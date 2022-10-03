module CandidateInterface
  class NewReferencesReviewComponent < ViewComponent::Base
    include ReferencesPathHelper
    attr_reader :references, :editable

    def initialize(application_form:, references:, application_choice: nil, editable: true, heading_level: 2, return_to_application_review: false, missing_error: false)
      @application_form = application_form
      @application_choice = application_choice
      @references = references
      @editable = editable
      @heading_level = heading_level
      @missing_error = missing_error
      @return_to_application_review = return_to_application_review
    end

    def show_missing_banner?
      @editable && @return_to_application_review.present? && !@application_form.references_completed?
    end

    def incomplete_section_params
      {
        section: :references_selected,
        section_path: candidate_interface_new_references_review_path,
        error: @missing_error,
      }.merge(incomplete_section_content)
    end

    def incomplete_section_content
      if @references.many? && @application_form.references_completed.blank?
        text = t('review_application.new_references.incomplete')
        link_text = t('review_application.new_references.complete_section')
      elsif @references.one?
        text = t('review_application.new_references.one_reference_only')
        link_text = t('review_application.new_references.add_more_references')
      else
        text = t('review_application.new_references.not_entered')
        link_text = t('review_application.new_references.enter_references')
      end

      {
        text:,
        link_text:,
      }
    end

    def reference_rows(reference)
      [
        reference_type_row(reference),
        name_row(reference),
        email_row(reference),
        relationship_row(reference),
        status_row(reference),
      ].compact
    end

    def ignore_editable_for
      %w[Status]
    end

  private

    def formatted_reference_type(reference)
      t("application_form.new_references.referee_type.#{reference.referee_type}.label")
    end

    def name_row(reference)
      action = if reference.feedback_provided?
                 {}
               else
                 {
                   action: {
                     href: reference_edit_name_path(
                       application_choice: @application_choice,
                       reference: reference,
                       return_to: return_to_params,
                       step: reference_workflow_step,
                     ),
                     visually_hidden_text: "name for #{reference.name}",
                   },
                 }
               end

      {
        key: t('review_application.new_references.name.label'),
        value: reference.name,
      }.merge(action)
    end

    def email_row(reference)
      edit_email_path = reference_edit_email_address_path(
        application_choice: @application_choice,
        reference: reference,
        return_to: return_to_params,
        step: reference_workflow_step,
      )
      action = if reference.feedback_provided?
                 {}
               else
                 {
                   action: {
                     href: edit_email_path,
                     visually_hidden_text: "email address for #{reference.name}",
                   },
                 }
               end

      if reference.email_address?
        {
          key: t('review_application.new_references.email.label'),
          value: reference.email_address,
        }.merge(action)
      else
        {
          key: t('review_application.new_references.email.label'),
          value: govuk_link_to('Enter email address', edit_email_path),
        }
      end
    end

    def relationship_row(reference)
      edit_relationship_path = reference_edit_relationship_path(
        application_choice: @application_choice,
        reference: reference,
        return_to: return_to_params,
        step: reference_workflow_step,
      )
      action = if reference.feedback_provided?
                 {}
               else
                 {
                   action: {
                     href: edit_relationship_path,
                     visually_hidden_text: "relationship for #{reference.name}",
                   },
                 }
               end

      if reference.relationship?
        {
          key: t('review_application.new_references.relationship.label'),
          value: reference.relationship,
        }.merge(action)
      else
        {
          key: t('review_application.new_references.relationship.label'),
          value: govuk_link_to('Enter how you know them and for how long', edit_relationship_path),
        }
      end
    end

    def reference_type_row(reference)
      action = if reference.feedback_provided?
                 {}
               else
                 {
                   action: {
                     href: reference_edit_type_path(
                       application_choice: @application_choice,
                       reference: reference,
                       return_to: return_to_params,
                       step: reference_workflow_step,
                     ),
                     visually_hidden_text: "reference type for #{reference.name}",
                   },
                 }
               end

      {
        key: t('review_application.new_references.type.label'),
        value: formatted_reference_type(reference),
      }.merge(action)
    end

    def status_row(reference)
      return nil unless reference.feedback_provided?

      {
        key: '',
        value: [
          t('application_form.new_references.status.first_line', name: reference.name),
          '',
          t('application_form.new_references.status.second_line'),
        ],
      }
    end

    def feedback_status_label(reference)
      render CandidateInterface::NewReferenceStatusesComponent.new(reference:)
    end

    def return_to_params
      if @return_to_application_review
        { 'return_to' => 'application-review' }
      else
        { 'return_to' => 'review' }
      end
    end

    def confirm_destroy_path(reference)
      candidate_interface_confirm_destroy_new_reference_path(reference)
    end
  end
end
