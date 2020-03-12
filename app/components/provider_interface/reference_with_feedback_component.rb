module ProviderInterface
  class ReferenceWithFeedbackComponent < ActionView::Component::Base
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
        safeguarding_row,
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
      return unless FeatureFlag.active?('referee_confirm_relationship_and_safeguarding')

      {
        key: 'Relationship confirmed by referee?',
        value: relationship_correction || 'Yes',
      }
    end

    def safeguarding_row
      return unless FeatureFlag.active?('referee_confirm_relationship_and_safeguarding')

      {
        key: 'Does the referee know of any reason why this candidate should not work with children?',
        value: safeguarding_concerns || 'No',
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

    attr_reader :reference
  end
end
