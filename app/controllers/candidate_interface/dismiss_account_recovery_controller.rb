module CandidateInterface
  class DismissAccountRecoveryController < CandidateInterfaceController
    def create
      current_candidate.account_recovery_status_dismissed!
      redirect_to candidate_interface_details_path
    end
  end
end
