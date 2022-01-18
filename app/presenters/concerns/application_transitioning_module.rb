# to remove once Notes and Withdrawals add the required fields
module ApplicationTransitioningModule
  def schema
    super.deep_merge!(attributes: {
      notes: [],
      withdrawn_at: nil,
      withdrawn_or_declined_for_candidate: nil,
    })
  end
end
