module RefereeInterface
  class FeedbackHintsComponent < ViewComponent::Base
    attr_reader :reference, :referee_type, :application

    def initialize(reference:)
      @reference = reference
      @referee_type = reference.referee_type
      @application = reference.application_form
    end

    delegate :full_name, to: :application

    def provider_name
      application.application_choices.pending_conditions.first.provider.name
    end

    def reference_hints
      repeated_bullet_points = {
        bp1: 'the dates they worked with you',
        bp2: 'their role and responsibilities',
      }
      hints = {
        school_based: repeated_bullet_points,
        professional: repeated_bullet_points,
        academic:
        {
          bp1: 'when their course started and ended',
          bp2: 'their academic performance',
        },
        character:
        {
          bp1: 'volunteering they’ve done with you',
          bp2: 'mentoring you’ve done for them',
          bp3: 'activities you’ve done together',
        },
      }

      hints[referee_type.to_sym]
    end
  end
end
