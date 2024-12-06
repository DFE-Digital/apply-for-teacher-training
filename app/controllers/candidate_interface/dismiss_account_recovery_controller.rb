class CandidateInterface::DismissAccountRecoveryController < ApplicationController
  def create
    current_candidate.update!(dismiss_recovery: true)
    redirect_to candidate_interface_details_path
  end
end
