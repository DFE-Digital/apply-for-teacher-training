module RefereeInterface
  class FeedbackHintsComponent < ApplicationComponent
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
      repeated = ['when they worked with you', 'their role and responsibilities']
      hints = {
        school_based: repeated,
        professional: repeated,
        academic: ['when their course started and ended', 'their academic record'],
        character: ["details of how you know #{candidate_full_name}", 'things they’ve done or you have done together'],
      }

      hints[referee_type.to_sym]
    end
  end
end
