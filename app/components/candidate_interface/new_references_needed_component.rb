module CandidateInterface
  class NewReferencesNeededComponent < ViewComponent::Base
    include ViewHelper

    validates :application_form, presence: true

    def initialize(application_form:)
      @application_form = application_form
    end

    def render?
      reference_status.still_more_references_needed? && EndOfCyclePolicy.can_add_course_choice?(application_form)
    end

    def pluralize_referee
      'referee'.pluralize(reference_status.not_requested_yet?.count)
    end

  private

    def reference_status
      @reference_status ||= ReferenceStatus.new(application_form)
    end

    attr_reader :application_form
  end
end
