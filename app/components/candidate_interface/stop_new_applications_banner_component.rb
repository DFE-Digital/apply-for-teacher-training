module CandidateInterface
  class StopNewApplicationsBannerComponent < ViewComponent::Base
    def initialize(application_form:)
      @application_form = application_form
    end

    def render?
      @application_form.submissions_closed? && !@application_form.submitted?
    end
  end
end
