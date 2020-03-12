module RefereeInterface
  class ReferenceReviewComponent < ActionView::Component::Base
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
        action: 'relationship',
        change_path: referee_interface_reference_relationship_path(token: @token_param),
      }
    end

    def safeguarding_concerns
      {
        key: 'Concerns about candidate working with children',
        value: @reference.safeguarding_concerns.presence || 'No',
        action: 'concerns about candidate working with children',
        change_path: referee_interface_safeguarding_path(token: @token_param),
      }
    end

    def reference
      {
        key: 'Reference',
        value: @reference.feedback,
        action: 'reference',
        change_path: referee_interface_reference_feedback_path(token: @token_param),
      }
    end

    def relationship_value
      return 'Confirmed by referee' if @reference.relationship_correction.blank?

      "Amended by referee to: #{@reference.relationship_correction}"
    end
  end
end
