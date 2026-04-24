module ApplicationStateAPIData
  def api_application_states
    if version >= '1.8'
      {
        offer_withdrawn: 'rejected',
        inactive: 'awaiting_provider_decision',
        interviewing: 'interviewing',
      }.freeze
    else
      {
        offer_withdrawn: 'rejected',
        inactive: 'awaiting_provider_decision',
        interviewing: 'awaiting_provider_decision',
      }.freeze
    end
  end
end
