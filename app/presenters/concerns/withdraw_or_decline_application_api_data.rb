module WithdrawOrDeclineApplicationAPIData
  def schema
    super.deep_merge!({
      attributes: {
        withdrawn_or_declined_for_candidate: application_choice.withdrawn_or_declined_for_candidate_by_provider,
      },
    })
  end
end
