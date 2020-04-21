module CandidateInterface
  class Degrees::DestroyController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def confirm_destroy
      current_qualification = current_application.application_qualifications.degrees.find(current_degree_id)
      @degree = DegreeForm.build_from_qualification(current_qualification)
    end

    def destroy
      current_application
        .application_qualifications
        .find(current_degree_id)
        .destroy!

      current_application.update!(degrees_completed: false)

      redirect_to candidate_interface_degrees_review_path
    end

  private

    def current_degree_id
      params.permit(:id)[:id]
    end
  end
end
