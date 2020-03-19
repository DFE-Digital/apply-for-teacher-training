module RefereeInterface
  class FeedbackHintsComponent < ActionView::Component::Base
    def initialize(reference:)
      @academic = reference.referee_type.nil? || reference.referee_type == 'academic'
    end
  end
end
