module SupportInterface
  class CandidatesController < SupportInterfaceController
    before_action :disable_on_production, only: :impersonate

    def index
      @candidates = Candidate
        .includes(application_forms: :application_choices)
        .sort_by { |candidate| (candidate.application_forms.collect(&:updated_at) + [candidate.updated_at]).max }
        .reverse
    end

    def show
      @candidate = Candidate.find(params[:candidate_id])
    end

    def hide_in_reporting
      candidate = Candidate.find(params[:candidate_id])
      candidate.update!(hide_in_reporting: true)
      flash[:success] = 'Candidate will now be hidden in reporting'
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
      flash[:success] = 'Candidate will now be shown in reporting'
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
      redirect_to candidate_interface_application_form_path
    end

  private

    def disable_on_production
      return unless HostingEnvironment.production?

      render_404
    end
  end
end
