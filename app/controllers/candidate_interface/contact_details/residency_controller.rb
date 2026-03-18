module CandidateInterface
  class ContactDetails::ResidencyController < CandidateInterfaceController
    def new
      @country_of_residence = country_of_residence
      @residency_form = CandidateInterface::ResidencyForm.new
    end

    def edit
      @country_of_residence = country_of_residence
      @residency_form = CandidateInterface::ResidencyForm.new # change to build from ...
      # @return_to = return_to_after_edit(default: candidate_interface_contact_information_review_path)
    end

    def create; end

    def update
      # @return_to = return_to_after_edit(default: candidate_interface_contact_information_review_path)
      # redirect_to @return_to[:back_path]
    end

  private

    def country_of_residence
      COUNTRIES_AND_TERRITORIES[current_application.country]
    end
  end
end
