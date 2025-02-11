module RefereeInterface
  class ReferenceReviewComponent < ViewComponent::Base
    def initialize(reference:, application_form:, token_param: nil, editable: true)
      @reference = reference
      @editable = editable
      @token_param = token_param
      @application_form = application_form
    end

    def reference_rows
      [relationship, safeguarding_concerns, reference, confidentiality]
    end

  private

    def relationship
      {
        key: (@reference.relationship_correction.presence ? 'How you know them' : 'How they know you'),
        value: relationship_value,
        action: {
          href: referee_interface_reference_relationship_path(token: @token_param, from: 'review'),
          visually_hidden_text: (@reference.relationship_correction.presence ? 'how you know them' : 'your confirmation of how they know you'),
        },
      }
    end

    def safeguarding_concerns
      concerns = if @reference.not_answered_yet? || @reference.never_asked?
                   'Not answered'
                 elsif @reference.no_safeguarding_concerns_to_declare?
                   'You do not know any reason why they should not work with children.'
                 else
                   @reference.safeguarding_concerns
                 end

      {
        key: 'Working with children',
        value: concerns,
        action: {
          href: referee_interface_safeguarding_path(token: @token_param, from: 'review'),
          visually_hidden_text: 'whether you know any reason they should not work with children',
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

    def confidentiality
      {
        key: "Can your reference be shared with #{@application_form.full_name}",
        value: @reference.confidential ? 'No' : 'Yes',
        action: {
          href: referee_interface_confidentiality_path(token: @token_param, from: 'review'),
          visually_hidden_text: "Can your reference be shared with #{@application_form.full_name}",
        },
      }
    end

    def relationship_value
      return 'Not answered' if @reference.relationship_correction.nil?

      if @reference.relationship_correction.presence
        "You said this is how you know them:\n\n#{@reference.relationship_correction}"
      else
        "You confirmed their description of how they know you:\n\n#{@reference.relationship}"
      end
    end
  end
end
