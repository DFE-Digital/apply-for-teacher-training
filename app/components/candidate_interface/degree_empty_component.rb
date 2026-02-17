module CandidateInterface
  class DegreeEmptyComponent < ApplicationComponent
    include UtmLinkHelper

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
      (degrees.pluck(:qualification_type) - CandidateInterface::DegreeTypeComponent.degree_types['Foundation degree'].collect { |degree| degree[:name] }).empty?
    end
  end
end
