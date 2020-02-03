module ProviderInterface
  class ReferenceWithFeedbackComponent < ActionView::Component::Base
    validates :reference, presence: true

    delegate :feedback,
             :name,
             :email_address,
             :relationship,
             to: :reference

    def initialize(reference:)
      @reference = reference
    end

    def rows
      [
        name_row,
        email_address_row,
        relationship_row,
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
        key: 'Relationship to candidate',
        value: relationship,
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
