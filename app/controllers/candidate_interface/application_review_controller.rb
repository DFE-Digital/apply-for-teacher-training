module CandidateInterface
  class ApplicationReviewController < CandidateInterfaceController
    before_action :authenticate_candidate!

    def show
      personal_details_form = PersonalDetailsForm.build_from_application(
        current_candidate.current_application,
        )
      @personal_details_review = PersonalDetailsReviewPresenter.new(personal_details_form)
    end
  end
end
