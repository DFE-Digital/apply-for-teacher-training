module ProviderInterface
  class ReferenceWithFeedbackComponent < ViewComponent::Base
    validates :reference, presence: true

    delegate :feedback,
             :name,
             :email_address,
             :relationship,
             :relationship_confirmation,
             :relationship_correction,
             :safeguarding_concerns,
             to: :reference

    def initialize(reference:)
      @reference = reference
    end

    def rows
      [
        name_row,
        email_address_row,
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
        value: safeguarding_concerns.present? ? 'Yes' : 'No',
      }
    end

    def safeguarding_concerns_row
      return nil if safeguarding_concerns.blank?

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
