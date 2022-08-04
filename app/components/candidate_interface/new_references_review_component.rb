module CandidateInterface
  class NewReferencesReviewComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :references, :editable, :is_errored

    def initialize(references:, editable: true, is_errored: false, heading_level: 2)
      @references = references
      @editable = editable
      @is_errored = is_errored
      @heading_level = heading_level
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
      {
        key: 'Name',
        value: reference.name,
        action: {
          href: candidate_interface_new_references_edit_name_path(reference.id, return_to: :review),
          visually_hidden_text: "name for #{reference.name}",
        },
      }
    end

    def email_row(reference)
      if reference.email_address?
        {
          key: 'Email',
          value: reference.email_address,
          action: {
            href: candidate_interface_new_references_edit_email_address_path(reference.id, return_to: :review),
            visually_hidden_text: "email address for #{reference.name}",
          },
        }
      else
        {
          key: 'Email',
          value: govuk_link_to(
            'Enter email address',
            candidate_interface_new_references_edit_email_address_path(
              reference.id, return_to: :review
            ),
          ),
        }
      end
    end

    def relationship_row(reference)
      if reference.relationship?
        {
          key: 'Relationship to you',
          value: reference.relationship,
          action: {
            href: candidate_interface_new_references_edit_relationship_path(reference.id, return_to: :review),
            visually_hidden_text: "relationship for #{reference.name}",
          },
        }
      else
        {
          key: 'Relationship to you',
          value: govuk_link_to(
            'Enter relationship to referee',
            candidate_interface_new_references_edit_relationship_path(
              reference.id, return_to: :review
            ),
          ),
        }
      end
    end

    def reference_type_row(reference)
      {
        key: 'Type',
        value: formatted_reference_type(reference),
        action: {
          href: candidate_interface_new_references_edit_type_path(reference.referee_type, reference.id, return_to: :review),
          visually_hidden_text: "reference type for #{reference.name}",
        },
      }
    end

    def status_row(reference)
      return nil unless reference.feedback_provided?

      double_break = tag.br + tag.br

      {
        key: 'Status',
        value: feedback_status_label(reference) + double_break + t('application_form.new_references.status.first_line', name: reference.name) + double_break + t('application_form.new_references.status.second_line'),
      }
    end

    def feedback_status_label(reference)
      govuk_tag(
        text: t("candidate_reference_status.#{reference.feedback_status}"),
        colour: t("candidate_reference_colours.#{reference.feedback_status}"),
      )
    end
  end
end
