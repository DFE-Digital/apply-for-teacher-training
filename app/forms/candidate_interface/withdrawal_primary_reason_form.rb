module CandidateInterface
  class WithdrawalPrimaryReasonForm < WithdrawalReasonsForm
    def reason_options
      get_reasons
    end
  end
end
