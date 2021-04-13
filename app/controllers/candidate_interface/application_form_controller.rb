module CandidateInterface
  class ApplicationFormController < CandidateInterfaceController
    def review_previous_application
      @application_form = current_candidate.application_forms.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end
