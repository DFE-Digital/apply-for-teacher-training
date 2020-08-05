module CandidateInterface
  class ApplicationFormController < CandidateInterfaceController
    def review_previous_application
      @application_form = current_candidate.application_forms.find(params[:id])
      @review_previous_application = true

      render 'candidate_interface/submitted_application_form/review_submitted'
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end
