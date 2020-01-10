module CandidateInterface
  class Degrees::GradeController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable

    def new
      @degree = DegreeForm.new
    end

    def edit
      current_qualification = current_application.application_qualifications.degrees.find(current_degree_id)
      @degree = DegreeForm.build_from_qualification(current_qualification)
    end

    def update
      @degree = DegreeForm.new(id: current_degree_id, attributes: degree_params)

      if @degree.update_grade(current_application)
        if award_year_nil?
          redirect_to candidate_interface_degrees_year_path(current_degree_id)
        else
          redirect_to candidate_interface_degrees_review_path
        end
      else
        render :new
      end
    end


  private

    def current_degree_id
      params.permit(:id)[:id]
    end

    def degree_params
      params.require(:candidate_interface_degree_form).permit(
        :grade, :other_grade, :predicted_grade
      ).transform_values(&:strip)
    end

    def award_year_nil?
      current_application.application_qualifications.find(current_degree_id).award_year.nil?
    end
  end
end
