module CandidateInterface
  class DegreesEmptyComponent < ViewComponent::Base
    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def render?
      degrees.empty? || only_foundation_degrees
    end

    def degrees
      application_form.application_qualifications.degree
    end

  private

    def only_foundation_degrees
      (degrees.pluck(:qualification_type) - CandidateInterface::DegreeTypeComponent::DEGREE_TYPES['Foundation degree']).empty?
    end
  end
end
