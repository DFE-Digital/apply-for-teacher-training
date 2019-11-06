module CandidateInterface
  class Degrees::DestroyController < CandidateInterfaceController
    def confirm_destroy
      application_form = current_candidate.current_application
      @degree = DegreeForm.build_from_application(application_form, current_degree_id)
    end

    def destroy
      current_candidate.current_application
        .application_qualifications
        .find(current_degree_id)
        .destroy!

      redirect_to candidate_interface_degrees_review_path
    end

  private

    def current_degree_id
      params.permit(:id)[:id]
    end
  end
end
