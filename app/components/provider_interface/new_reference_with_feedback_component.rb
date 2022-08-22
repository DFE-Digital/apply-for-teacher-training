module ProviderInterface
  class NewReferenceWithFeedbackComponent < ViewComponent::Base
    attr_accessor :reference, :index, :application_choice
    delegate :feedback,
             :name,
             :email_address,
             :referee_type,
             :relationship,
             :relationship_confirmation,
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
      [
        name_row,
        email_address_row,
        reference_type_row,
        relationship_row,
        relationship_confirmation_row,
        relationship_correction_row,
        safeguarding_row,
        safeguarding_concerns_row,
        feedback_row,
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

    def reference_type_row
      {
        key: 'Type of reference',
        value: referee_type ? referee_type.capitalize.dasherize : '',
      }
    end

    def relationship_row
      {
        key: 'Relationship between candidate and referee',
        value: relationship,
      }
    end

    def relationship_confirmation_row
      return if no_offer_yet?

      {
        key: 'Relationship confirmed by referee?',
        value: relationship_correction.present? ? 'No' : 'Yes',
      }
    end

    def relationship_correction_row
      return if relationship_correction.blank? || no_offer_yet?

      {
        key: 'Relationship amended by referee',
        value: relationship_correction,
      }
    end

    def safeguarding_row
      return if no_offer_yet?

      {
        key: 'Does the referee know of any reason why this candidate should not work with children?',
        value: reference.has_safeguarding_concerns_to_declare? ? 'Yes' : 'No',
      }
    end

    def safeguarding_concerns_row
      return if no_offer_yet? || !reference.has_safeguarding_concerns_to_declare?

      {
        key: 'Reason(s) given by referee why this candidate should not work with children',
        value: safeguarding_concerns,
      }
    end

    def feedback_row
      return if no_offer_yet? || feedback.nil?

      {
        key: 'Reference',
        value: feedback,
      }
    end

    def no_offer_yet?
      ApplicationStateChange::OFFERED_STATES.exclude? application_choice.status.to_sym
    end
  end
end
