module CandidateInterface
  class CourseChoicesSummaryCardActionComponent < ViewComponent::Base
    attr_reader :action, :application_choice

    def initialize(action:, application_choice:)
      @action = action
      @application_choice = application_choice
    end
  end
end
