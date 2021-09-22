module RefereeInterface
  class ReferenceReviewComponent < ViewComponent::Base
    def initialize(reference:, token_param: nil, editable: true)
      @reference = reference
      @editable = editable
      @token_param = token_param
    end

    def reference_rows
      [relationship, safeguarding_concerns, reference]
    end

  private

    def relationship
      {
        key: 'Relationship',
        value: relationship_value,
        action: {
          href: referee_interface_reference_relationship_path(token: @token_param, from: 'review'),
          visually_hidden_text: 'relationship',
        },
      }
    end

    def safeguarding_concerns
      concerns = if @reference.not_answered_yet? || @reference.never_asked?
                   'Not answered'
                 elsif @reference.no_safeguarding_concerns_to_declare?
                   'No'
                 else
                   @reference.safeguarding_concerns
                 end

      {
        key: 'Concerns about candidate working with children',
        value: concerns,
        action: {
          href: referee_interface_safeguarding_path(token: @token_param, from: 'review'),
          visually_hidden_text: 'concerns about candidate working with children',
        },
      }
    end

    def reference
      {
        key: 'Reference',
        value: @reference.feedback || 'Not answered',
        action: {
          href: referee_interface_reference_feedback_path(token: @token_param, from: 'review'),
          visually_hidden_text: 'reference',
        },
      }
    end

    def relationship_value
      return 'Not answered' if @reference.relationship_correction.nil?

      @reference.relationship_correction.presence || 'You’ve confirmed your relationship with the candidate'
    end
  end
end
