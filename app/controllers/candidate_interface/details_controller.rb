module CandidateInterface
  class DetailsController < ContinuousApplicationsController
    def index
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)
      @application_cache_key = CacheKey.generate(@application_form_presenter.cache_key_with_version)
      @adviser_sign_up = Adviser::SignUp.new(current_application)

      track_adviser_offering if @adviser_sign_up.available?
    end
  end
end
