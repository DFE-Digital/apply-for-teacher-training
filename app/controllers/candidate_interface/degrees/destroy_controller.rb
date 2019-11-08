module CandidateInterface
  class Degrees::DestroyController < CandidateInterfaceController
    def confirm_destroy
      @degree = DegreeForm.build_from_application(current_application, current_degree_id)
    end

    def destroy
      current_application
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
