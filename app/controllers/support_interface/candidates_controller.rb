module SupportInterface
  class CandidatesController < SupportInterfaceController
    before_action :disable_on_production, only: :impersonate

    PAGY_PER_PAGE = 30

    def index
      authorize(nil, :show?, policy_class: SupportInterface::CandidatePolicy)

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
      authorize(nil, :show?, policy_class: SupportInterface::CandidatePolicy)

      @candidate = Candidate.find(params.expect(:candidate_id))
      @candidate_account_status = SupportInterface::CandidateAccountStatusForm.new(candidate: @candidate)
      @application_forms = @candidate.application_forms.order(updated_at: :desc)
    end

    def impersonate
      authorize(nil, :edit?, policy_class: SupportInterface::CandidatePolicy)

      candidate = Candidate.find(params.expect(:candidate_id))
      # bypass_sign_in will not update the database when signing in
      # https://stackoverflow.com/questions/50405133/devise-bypass-sign-in-without-active-for-authentication-callback#50409127
      bypass_sign_in(candidate, scope: :candidate)

      flash[:success] = "You are now signed in as candidate #{candidate.email_address}"

      redirect_to candidate_interface_interstitial_path
    end

    def edit_candidate_account_status
      authorize(nil, :edit?, policy_class: SupportInterface::CandidatePolicy)

      @candidate = Candidate.find(params.expect(:candidate_id))
      @candidate_account_status = SupportInterface::CandidateAccountStatusForm.new(
        candidate: @candidate,
      )
    end

    def update_candidate_account_status
      authorize(nil, :edit?, policy_class: SupportInterface::CandidatePolicy)

      @candidate = Candidate.find(params.expect(:candidate_id))
      @candidate_account_status = SupportInterface::CandidateAccountStatusForm.new(
        candidate_account_status_params,
      )
      @candidate_account_status.update!

      redirect_to support_interface_candidate_path(@candidate)
    end

    def update_multiple_candidate_account_statuses
      authorize(nil, :edit?, policy_class: SupportInterface::CandidatePolicy)

      candidate_ids = multiple_candidate_account_status_params[:candidate_ids]

      status = multiple_candidate_account_status_params[:status]

      candidate_ids.each do |candidate_id|
        candidate = Candidate.find(candidate_id)
        candidate_account_status_form = SupportInterface::CandidateAccountStatusForm.new(
          candidate: candidate,
          status:,
        )
        candidate_account_status_form.update!
      end

      match = DuplicateMatch.find(multiple_candidate_account_status_params[:match_id])

      num_unlocked_accounts = match.reload.candidates.where(submission_blocked: false, account_locked: false).count

      flash[:success] = if status == 'account_access_locked'
                          [t('.account_locked', count: candidate_ids.size)]
                        else
                          [t('.account_unlocked', count: candidate_ids.size, num_unlocked_accounts: num_unlocked_accounts)]
                        end

      if candidate_ids.size == 1 && num_unlocked_accounts >= 2
        flash[:success] << t('.account_unlocked_description', count: num_unlocked_accounts)
      end

      redirect_to support_interface_duplicate_match_path(id: match.id)
    end

    def edit_candidate_email_address
      authorize(nil, :edit?, policy_class: SupportInterface::CandidatePolicy)

      @match = DuplicateMatch.find(params.expect(:match_id))
      @candidate = @match.candidates.find(params.expect(:candidate_id))
      @candidate_email_addresses = @match.candidates.pluck(:email_address)
    end

    def update_candidate_email_address
      authorize(nil, :edit?, policy_class: SupportInterface::CandidatePolicy)

      @candidate = Candidate.find(params.expect(:candidate_id))
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

    def multiple_candidate_account_status_params
      params.expect(
        support_interface_multiple_candidate_account_status_form: [:status,
                                                                   :match_id,
                                                                   candidate_ids: []],
      )
    end
  end
end
