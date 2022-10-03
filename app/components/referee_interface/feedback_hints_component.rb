module RefereeInterface
  class FeedbackHintsComponent < ViewComponent::Base
    attr_reader :reference, :referee_type, :application

    def initialize(reference:)
      @reference = reference
      @referee_type = reference.referee_type
      @application = reference.application_form
    end

    delegate :full_name, to: :application, prefix: :candidate

    def provider_name
      application.application_choices.select(&:accepted_choice?).first.provider.name
    end

    def reference_hints
      repeated = ['the dates they worked with you', 'their role and responsibilities']
      hints = {
        school_based: repeated,
        professional: repeated,
        academic: ['when their course started and ended', 'their academic performance'],
        character: ['volunteering they’ve done with you', 'mentoring you’ve done for them', 'activities you’ve done together'],
      }

      hints[referee_type.to_sym]
    end
  end
end
