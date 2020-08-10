module CandidateInterface
  class FindDownCourseChoicesBanner < ViewComponent::Base
    validates :application_form, presence: true

    def initialize(application_form:)
      @application_form = application_form
    end
  end
end
