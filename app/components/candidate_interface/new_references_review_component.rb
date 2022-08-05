
module CandidateInterface
  class NewReferencesReviewComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :references, :editable

    def initialize(application_form:, references:, editable: true, heading_level: 2, return_to_application_review: false, missing_error: false)
      @application_form = application_form
      @references = references
      @editable = editable
      @heading_level = heading_level
      @missing_error = missing_error
      @return_to_application_review = return_to_application_review
    end

    def show_missing_banner?
      @editable && !@application_form.references_completed?
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
        text: text,
        link_text: link_text,
      }
    end

    def card_title(index)
      "#{reference_number(index)} reference"
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
      reference.referee_type ? reference.referee_type.capitalize.dasherize : ''
    end

    def reference_number(index)
      TextOrdinalizer.call((index + 1)).capitalize
    end

    def name_row(reference)
      action = if reference.feedback_provided?
                 {}
               else
                 {
                   action: {
                     href: edit_name_path(reference, return_to_params),
                     visually_hidden_text: "name for #{reference.name}",
                   },
                 }
               end

      {
        key: 'Name',
        value: reference.name,
      }.merge(action)
    end

    def edit_name_path(reference)
      candidate_interface_new_references_edit_name_path(reference.id, return_to_params)
    end

    def email_row(reference)
      action = if reference.feedback_provided?
                 {}
               else
                 {
                   action: {
                     href: edit_email_address_path(reference, return_to_params),
                     visually_hidden_text: "email address for #{reference.name}",
                   },
                 }
               end

      if reference.email_address?
        {
          key: 'Email',
          value: reference.email_address,
        }.merge(action)
      else
        {
          key: 'Email',
          value: govuk_link_to(
            'Enter email address',
            edit_email_address_path(reference, return_to_params),
          ),
        }
      end
    end

    def edit_email_address_path(reference, return_params)
      candidate_interface_new_references_edit_relationship_path(
        reference.id,
        return_params,
      )
    end

    def relationship_row(reference)
      action = if reference.feedback_provided?
                 {}
               else
                 {
                   action: {
                     href: edit_relationship_path(reference, return_to_params),
                     visually_hidden_text: "relationship for #{reference.name}",
                   },
                 }
               end

      if reference.relationship?
        {
          key: 'Relationship to you',
          value: reference.relationship,
        }.merge(action)
      else
        {
          key: 'Relationship to you',
          value: govuk_link_to(
            'Enter relationship to referee',
            edit_relationship_path(reference, return_to_params),
          ),
        }
      end
    end

    def edit_relationship_path(reference, return_params)
      candidate_interface_new_references_edit_relationship_path(
        reference.id,
        return_params,
      )
    end

    def reference_type_row(reference)
      action = if reference.feedback_provided?
                 {}
               else
                 {
                   action: {
                     href:  edit_type_path(reference, return_to_params),
                     visually_hidden_text: "reference type for #{reference.name}",
                   },
                 }
               end

      {
        key: 'Type',
        value: formatted_reference_type(reference),
      }.merge(action)
    end

    def status_row(reference)
      return nil unless reference.feedback_provided?

      double_break = tag.br + tag.br

      {
        key: 'Status',
        value: feedback_status_label(reference) + double_break + t('application_form.new_references.status.first_line', name: reference.name) + double_break + t('application_form.new_references.status.second_line'),
      }
    end

    def edit_type_path(reference)
      candidate_interface_new_references_edit_type_path(reference.referee_type, reference.id, return_to_params)
    end

    def feedback_status_label(reference)
      govuk_tag(
        text: t("candidate_reference_status.#{reference.feedback_status}"),
        colour: t("candidate_reference_colours.#{reference.feedback_status}"),
      )
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
