module CandidateInterface
  class ApplicationFormPresenter
    def initialize(application_form)
      @application_form = application_form
    end

    def personal_details_completed?
      CandidateInterface::PersonalDetailsForm.build_from_application(@application_form).valid?
    end
  end
end
