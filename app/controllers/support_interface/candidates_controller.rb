module SupportInterface
  class CandidatesController < SupportInterfaceController
    def index
      @candidates = Candidate
        .includes(:application_forms)
        .order('candidates.updated_at desc')
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
  end
end
