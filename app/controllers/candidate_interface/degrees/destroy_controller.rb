module CandidateInterface
  class Degrees::DestroyController < CandidateInterfaceController
    def confirm_destroy
      application_form = current_candidate.current_application
      @degree = DegreesForm.build_from_application(application_form, degrees_params[:id])
    end

    def destroy
      current_candidate.current_application
        .application_qualifications
        .find(degrees_params[:id])
        .destroy!

      redirect_to candidate_interface_degrees_review_path
    end

  private

    def degrees_params
      params.permit(:id)
    end
  end
end
