module ProviderInterface
  class NewReferenceWithFeedbackComponent < ViewComponent::Base
    attr_accessor :reference, :index, :application_choice
    delegate :feedback,
             :feedback_provided?,
             :duplicate?,
             :name,
             :email_address,
             :relationship,
             :relationship_correction,
             :safeguarding_concerns,
             :safeguarding_concerns_status,
             to: :reference

    def initialize(reference:, index:, application_choice:)
      @reference = reference
      @index = index
      @application_choice = application_choice
    end

    def rows
      base_rows = [
        name_row,
        email_address_row,
        relationship_row,
        safeguarding_row,
        feedback_row,
      ].compact

      base_rows += [confidentiality_row] if feature_active_and_feedback_provided?

      base_rows
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
      return if application_choice.pre_offer? || reference_not_provided?

      {
        key: 'Concerns about the candidate working with children',
        value: reference.has_safeguarding_concerns_to_declare? ? safeguarding_concerns : 'No concerns.',
      }
    end

    def feedback_row
      return if application_choice.pre_offer? || feedback.nil?

      {
        key: duplicate? ? 'Does the candidate have the potential to teach?' : 'Reference',
        value: feedback,
      }
    end

    def confidentiality_row
      {
        key: 'Can this reference be shared with the candidate?',
        value: confidentiality_value,
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

    def reference_not_provided?
      !feedback_provided?
    end

    def confidentiality_value
      reference.confidential ? 'No, this reference is confidential. Do not share it.' : 'Yes, if they request it.'
    end

    def feature_active_and_feedback_provided?
      FeatureFlag.active?(:show_reference_confidentiality_status) && reference.feedback_provided?
    end
  end
end
