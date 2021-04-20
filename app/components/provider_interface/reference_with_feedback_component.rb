module ProviderInterface
  class ReferenceWithFeedbackComponent < ViewComponent::Base
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

    def initialize(reference:, index:)
      @reference = reference
      @ordinal = TextOrdinalizer.call((index + 1))
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
        value: govuk_mail_to(email_address, email_address),
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
      {
        key: 'Relationship confirmed by referee?',
        value: relationship_correction.present? ? 'No' : 'Yes',
      }
    end

    def relationship_correction_row
      return if relationship_correction.blank?

      {
        key: 'Relationship amended by referee',
        value: relationship_correction,
      }
    end

    def safeguarding_row
      {
        key: 'Does the referee know of any reason why this candidate should not work with children?',
        value: reference.has_safeguarding_concerns_to_declare? ? 'Yes' : 'No',
      }
    end

    def safeguarding_concerns_row
      return nil unless reference.has_safeguarding_concerns_to_declare?

      {
        key: 'Reason(s) given by referee why this candidate should not work with children',
        value: safeguarding_concerns,
      }
    end

    def feedback_row
      {
        key: 'Reference',
        value: feedback.nil? ? 'Not answered' : feedback,
      }
    end

    attr_reader :reference
  end
end
