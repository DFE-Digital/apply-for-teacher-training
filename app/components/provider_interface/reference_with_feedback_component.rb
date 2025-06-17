module ProviderInterface
  class ReferenceWithFeedbackComponent < ViewComponent::Base
    attr_accessor :reference, :application_choice
    delegate :feedback,
             :feedback_provided?,
             :duplicate?,
             :name,
             :email_address,
             :relationship,
             :relationship_correction,
             :safeguarding_concerns,
             :safeguarding_concerns_status,
             :confidential?,
             to: :reference
    delegate :accepted_choice?, to: :application_choice

    def initialize(reference:, application_choice:)
      @reference = reference
      @application_choice = application_choice
    end

    def warning_text
      return unless confidential? && feedback_provided?

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

    def name_row
      {
        key: 'Name',
        value: name,
      }
    end

    def email_address_row
      {
        key: 'Email address',
        value: email_address,
      }
    end

    def relationship_row
      {
        key: 'How the candidate knows them and how long for',
        value: relationship_value,
      }
    end

    def safeguarding_row
      return unless accepted_choice? && feedback_provided?

      {
        key: 'Concerns about the candidate working with children',
        value: reference.has_safeguarding_concerns_to_declare? ? safeguarding_concerns : 'No concerns.',
      }
    end

    def feedback_row
      return unless accepted_choice? && feedback.present?

      {
        key: duplicate? ? 'Does the candidate have the potential to teach?' : 'Reference',
        value: feedback,
      }
    end

    def confidentiality_row
      return unless feedback_provided?

      {
        key: 'Can this reference be shared with the candidate?',
        value: reference.confidential ? 'No, this reference is confidential. Do not share it.' : 'Yes, if they request it.',
      }
    end

    def relationship_value
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
      elsif feedback_provided? && relationship_correction.blank?
        [
          relationship,
          I18n.t(
            'provider_interface.references.confirmed_by',
            name: name,
          ),
        ].join("\n\n")
      else
        relationship
      end
    end
  end
end
