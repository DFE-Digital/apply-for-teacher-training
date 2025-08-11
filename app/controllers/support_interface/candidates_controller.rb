module SupportInterface
  class CandidatesController < SupportInterfaceController
    before_action :disable_on_production, only: :impersonate

    PAGY_PER_PAGE = 30

    def index
      @candidates = Candidate
                      .includes(application_forms: :application_choices)
                      .order(updated_at: :desc)

      @filter = SupportInterface::CandidatesFilter.new(params:)

      if @filter.applied_filters[:q].present?
        @candidates = @candidates.where('CONCAT(email_address) ILIKE ?', "%#{@filter.applied_filters[:q]}%")
      end

      if @filter.applied_filters[:candidate_number].present?
        candidate_number = @filter.applied_filters[:candidate_number].tr('^0-9', '')
        @candidates = @candidates.where(id: candidate_number)
      end

      @pagy, @candidates = pagy(@candidates, limit: PAGY_PER_PAGE)
    end

    def show
      @candidate = Candidate.find(params[:candidate_id])
      @candidate_account_status = SupportInterface::CandidateAccountStatusForm.new(candidate: @candidate)
      @application_forms = @candidate.application_forms.order(updated_at: :desc)
    end

    def hide_in_reporting
      candidate = Candidate.find(params[:candidate_id])
      candidate.update!(hide_in_reporting: true)
      flash[:success] = 'Candidate will now be excluded from service performance data'
      if params[:from_application_form_id]
        application_form_to_return_to = ApplicationForm.find(params[:from_application_form_id])
        redirect_to support_interface_application_form_path(application_form_to_return_to)
      else
        redirect_to support_interface_candidate_path(candidate)
      end
    end

    def show_in_reporting
      candidate = Candidate.find(params[:candidate_id])
      candidate.update!(hide_in_reporting: false)
      flash[:success] = 'Candidate will now be included in service performance data'
      if params[:from_application_form_id]
        application_form_to_return_to = ApplicationForm.find(params[:from_application_form_id])
        redirect_to support_interface_application_form_path(application_form_to_return_to)
      else
        redirect_to support_interface_candidate_path(candidate)
      end
    end

    def impersonate
      candidate = Candidate.find(params[:candidate_id])
      # bypass_sign_in will not update the database when signing in
      # https://stackoverflow.com/questions/50405133/devise-bypass-sign-in-without-active-for-authentication-callback#50409127
      bypass_sign_in(candidate, scope: :candidate)

      flash[:success] = "You are now signed in as candidate #{candidate.email_address}"

      redirect_to candidate_interface_interstitial_path
    end

    def edit_candidate_account_status
      @candidate = Candidate.find(params[:candidate_id])
      @candidate_account_status = SupportInterface::CandidateAccountStatusForm.new(
        candidate: @candidate,
      )
    end

    def update_candidate_account_status
      @candidate = Candidate.find(params[:candidate_id])
      @candidate_account_status = SupportInterface::CandidateAccountStatusForm.new(
        candidate_account_status_params,
      )
      @candidate_account_status.update!

      redirect_to support_interface_candidate_path(@candidate)
    end

  private

    def disable_on_production
      return unless HostingEnvironment.production?

      render_404
    end

    def candidate_account_status_params
      { candidate: @candidate }.merge(
        params.expect(support_interface_candidate_account_status_form: [:status]),
      )
    end
  end
end
