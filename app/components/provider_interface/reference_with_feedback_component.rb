module ProviderInterface
  class ReferenceWithFeedbackComponent < ViewComponent::Base
    attr_accessor :reference, :application_choice
    delegate :feedback,
             :feedback_provided?,
             :name,
             :email_address,
             :relationship,
             :relationship_correction,
             :safeguarding_concerns,
             :safeguarding_concerns_status,
             :confidential?,
             to: :reference
    delegate :accepted_choice?, to: :application_choice

    with_collection_parameter :reference

    def initialize(reference:, application_choice:)
      @reference = reference
      @application_choice = application_choice
    end

    def warning_text
      return unless display_referee_input? && confidential?

      I18n.t('provider_interface.references.confidential_warning')
    end

    def rows
      [
        name_row,
        email_address_row,
        relationship_row,
        safeguarding_row,
        feedback_row,
        confidentiality_row,
      ].compact
    end

  private

    def display_referee_input?
      accepted_choice? && feedback_provided?
    end

    def name_row
      {
        key: I18n.t('provider_interface.references.name_row.key'),
        value: name,
      }
    end

    def email_address_row
      {
        key: I18n.t('provider_interface.references.email_address_row.key'),
        value: email_address,
      }
    end

    def relationship_row
      {
        key: I18n.t('provider_interface.references.relationship_row.key'),
        value: relationship_value,
      }
    end

    def safeguarding_row
      return unless display_referee_input?

      {
        key: I18n.t('provider_interface.references.safeguarding_row.key'),
        value: reference.has_safeguarding_concerns_to_declare? ? safeguarding_concerns : I18n.t('provider_interface.references.safeguarding_row.value.no_concern'),
      }
    end

    def feedback_row
      return unless display_referee_input?

      {
        key: I18n.t('provider_interface.references.feedback_row.key'),
        value: feedback,
      }
    end

    def confidentiality_row
      return unless display_referee_input?

      {
        key: I18n.t('provider_interface.references.confidentiality_row.key'),
        value: I18n.t(confidential?, scope: 'provider_interface.references.confidentiality_row.value'),
      }
    end

    def relationship_value
      return relationship unless display_referee_input?

      if relationship_correction.present?
        [
          [
            I18n.t('provider_interface.references.candidate_has_said'),
            relationship,
          ].join("\n"),
          [
            I18n.t(
              'provider_interface.references.referee_has_said',
              name: name,
            ),
            relationship_correction,
          ].join("\n"),
        ].join("\n\n")
      else
        [
          relationship,
          I18n.t(
            'provider_interface.references.confirmed_by',
            name: name,
          ),
        ].join("\n\n")
      end
    end
  end
end
