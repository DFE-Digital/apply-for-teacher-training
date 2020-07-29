module CandidateInterface
  class StopNewApplicationsBannerComponent < ViewComponent::Base
    def initialize(application_form:)
      @application_form = application_form
    end

    def render?
      FeatureFlag.active?('stop_new_applications') && @application_form.submitted? == false
    end
  end
end
