module ProviderInterface
  class ReferenceWithFeedbackComponent < ActionView::Component::Base
    validates :reference, presence: true

    delegate :feedback,
             :name,
             :email_address,
             :relationship,
             :relationship_confirmation,
             :relationship_correction,
             to: :reference

    def initialize(reference:)
      @reference = reference
    end

    def rows
      [
        name_row,
        email_address_row,
        relationship_row,
        relationship_confirmation_or_correction_row,
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

    def relationship_confirmation_or_correction_row
#      return unless FeatureFlag.active?('referee_confirm_relationship_and_safeguarding')

      {
        key: 'Relationship confirmed by referee?',
        value: confirmation_or_correction,
      }
    end

    def feedback_row
      if feedback
        {
          key: 'Reference',
          value: feedback,
        }
      end
    end

    def confirmation_or_correction
      return relationship_correction if relationship_correction.present?

      'Yes'
    end

    attr_reader :reference
  end
end
