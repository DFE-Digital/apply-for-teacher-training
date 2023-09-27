module CandidateInterface
  class PersonalDetailsReviewComponent < ViewComponent::Base
    def initialize(application_form:, editable: true, missing_error: false, return_to_application_review: false)
      @application_form = application_form
      @personal_details_form = CandidateInterface::PersonalDetailsForm.build_from_application(
        application_form,
      )
      @nationalities_form = CandidateInterface::NationalitiesForm.build_from_application(
        application_form,
      )

      @right_to_work_or_study_form = CandidateInterface::ImmigrationRightToWorkForm.build_from_application(
        application_form,
      )
      @editable = editable
      @missing_error = missing_error
      @return_to_application_review = return_to_application_review
    end

    def rows
      CandidateInterface::PersonalDetailsReviewPresenter.new(
        personal_details_form: @personal_details_form,
        nationalities_form: @nationalities_form,
        application_form: @application_form,
        right_to_work_form: @right_to_work_or_study_form,
        return_to_application_review: @return_to_application_review,
        editable: @editable,
      ).rows
    end

    def show_missing_banner?
      @editable && !@application_form.personal_details_completed
    end

    def show_invalid_banner?
      @editable &&
        !PersonalDetailsForm.build_from_application(@application_form).valid_for_submission?
    end

  private

    attr_reader :application_form
  end
end
