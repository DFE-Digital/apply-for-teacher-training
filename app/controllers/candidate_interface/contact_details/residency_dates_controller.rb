module CandidateInterface
  class ContactDetails::ResidencyDatesController < CandidateInterfaceController
    def new; end

    def edit
      # @return_to = return_to_after_edit(default: candidate_interface_contact_information_review_path)
    end

    def create; end

    def update
      # @return_to = return_to_after_edit(default: candidate_interface_contact_information_review_path)
      # redirect_to @return_to[:back_path]
    end
  end
end
