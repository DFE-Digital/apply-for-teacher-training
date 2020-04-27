module CandidateInterface
  class Covid19DashboardBannerComponent < ViewComponent::Base
    def initialize(application_form:)
      @application_form = application_form
    end

    def render?
      FeatureFlag.active?('covid_19') && @application_form.any_enrolled? == false
    end
  end
end
