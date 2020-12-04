module SupportInterface
  class UCASMatchesController < SupportInterfaceController
    def index
      @filter = SupportInterface::UCASMatchesFilter.new(params: params)
      @matches = @filter.filter_records(UCASMatch.includes(:candidate))
        .order(updated_at: :desc)
        .page(params[:page] || 1).per(30)
    end

    def show
      @match = UCASMatch.find(params[:id])
    end

    def audit
      @match = UCASMatch.find(params[:id])
    end

    def record_ucas_withdrawal_requested
      match = UCASMatch.find(params[:id])
      match.update!(
        candidate_last_contacted_at: Time.zone.now,
        action_taken: 'ucas_withdrawal_requested',
      )
      flash[:success] = 'The date of requesting withdrawal from UCAS was recorded'
      redirect_to support_interface_ucas_match_path(match)
    end
  end
end
