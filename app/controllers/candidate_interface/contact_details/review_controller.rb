module CandidateInterface
  class ContactDetails::ReviewController < CandidateInterfaceController
    def show
      @contact_details_form = ContactDetailsForm.build_from_application(
        current_candidate.current_application,
      )
    end
  end
end
