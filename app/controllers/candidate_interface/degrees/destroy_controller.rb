module CandidateInterface
  class Degrees::DestroyController < CandidateInterfaceController
    def confirm_destroy
      application_form = current_candidate.current_application
      @degree = DegreeForm.build_from_application(application_form, degree_id_params)
    end

    def destroy
      current_candidate.current_application
        .application_qualifications
        .find(degree_id_params)
        .destroy!

      redirect_to candidate_interface_degrees_review_path
    end

  private

    def degree_id_params
      params.permit(:id)[:id]
    end
  end
end
