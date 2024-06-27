module CandidateInterface
  class ReferencesReviewComponent < ViewComponent::Base
    attr_reader :references, :editable

    def initialize(application_form:, references:, reference_process:, application_choice: nil, editable: true, heading_level: 2, return_to_application_review: false, missing_error: false, deletable: true)
      @application_form = application_form
      @application_choice = application_choice
      @references = references
      @editable = editable
      @heading_level = heading_level
      @missing_error = missing_error
      @return_to_application_review = return_to_application_review
      @deletable = deletable
      @reference_process = reference_process
    end

    def show_missing_banner?
      @editable && @return_to_application_review.present? && !@application_form.references_completed?
    end

    def incomplete_section_params
      {
        section: :references_selected,
        section_path: candidate_interface_references_review_path(@reference_process),
        error: @missing_error,
      }.merge(incomplete_section_content)
    end

    def incomplete_section_content
      if @references.many? && !@application_form.references_completed?
        text = t('review_application.references.incomplete')
        link_text = t('review_application.references.complete_section')
      elsif @references.one?
        text = t('review_application.references.one_reference_only')
        link_text = t('review_application.references.add_more_references')
      else
        text = t('review_application.references.not_entered')
        link_text = t('review_application.references.enter_references')
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

    def deletable?
      @editable && @deletable
    end

  private

    def formatted_reference_type(reference)
      t("application_form.references.referee_type.#{reference.referee_type}.label")
    end

    def name_row(reference)
      action = if reference.feedback_provided?
                 {}
               else
                 {
                   action: {
                     href: candidate_interface_references_edit_name_path(
                       @reference_process,
                       reference,
                       params: edit_path_params(reference),
                     ),
                     visually_hidden_text: "name for #{reference.name}",
                   },
                 }
               end

      {
        key: t('review_application.references.name.label'),
        value: reference.name,
      }.merge(action)
    end

    def email_row(reference)
      edit_email_path = candidate_interface_references_edit_email_address_path(
        @reference_process,
        reference,
        params: edit_path_params(reference),
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
          key: t('review_application.references.email.label'),
          value: reference.email_address,
        }.merge(action)
      else
        {
          key: t('review_application.references.email.label'),
          value: govuk_link_to('Enter email address', edit_email_path),
        }
      end
    end

    def relationship_row(reference)
      edit_relationship_path = candidate_interface_references_edit_relationship_path(
        @reference_process,
        reference,
        params: edit_path_params(reference),
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
          key: t('review_application.references.relationship.label'),
          value: reference.relationship,
        }.merge(action)
      else
        {
          key: t('review_application.references.relationship.label'),
          value: govuk_link_to('Enter how you know them and for how long', edit_relationship_path),
        }
      end
    end

    def reference_type_row(reference)
      if reference.referee_type?
        action = if reference.feedback_provided?
                   {}
                 else
                   {
                     action: {
                       href: candidate_interface_references_edit_type_path(
                         @reference_process,
                         reference,
                         params: edit_path_params(reference),
                       ),
                       visually_hidden_text: "reference type for #{reference.name}",
                     },
                   }
                 end

        {
          key: t('review_application.references.type.label'),
          value: formatted_reference_type(reference),
        }.merge(action)
      else
        type_path = candidate_interface_references_edit_type_path(
          { id: reference.id }.merge(edit_path_params(reference).symbolize_keys),
        )
        {
          key: t('review_application.references.type.label'),
          value: govuk_link_to('Choose a type of referee', type_path),
        }
      end
    end

    def status_row(reference)
      return nil unless reference.feedback_provided?

      {
        key: '',
        value: [
          t('application_form.references.status.first_line', name: reference.name),
          '',
          t('application_form.references.status.second_line'),
        ],
      }
    end

    def feedback_status_label(reference)
      render CandidateInterface::ReferenceStatusesComponent.new(reference:)
    end

    def edit_path_params(reference)
      {
        application_id: @application_choice&.id,
        return_to_path: return_to_path(reference),
      }
    end

    def return_to_path(reference)
      case @reference_process
      when 'candidate-details'
        candidate_interface_references_review_path(@reference_process)
      when 'accept-offer'
        candidate_interface_accept_offer_path(@application_choice)
      when 'request-reference'
        candidate_interface_new_references_review_path(
          @reference_process,
          reference,
        )
      end
    end

    def reference_editable?(reference)
      !reference.duplicate?
    end

    def confirm_destroy_path(reference)
      candidate_interface_confirm_destroy_new_reference_path(@reference_process, reference)
    end
  end
end
