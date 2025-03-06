module CandidateInterface
  class DetailsController < CandidateInterfaceController
    before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
    before_action CarryOverFilter

    def index
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)
      @application_cache_key = CacheKey.generate(@application_form_presenter.cache_key_with_version)

      track_adviser_offering if current_application.eligible_to_sign_up_for_a_teaching_training_adviser?
    end
  end
end
