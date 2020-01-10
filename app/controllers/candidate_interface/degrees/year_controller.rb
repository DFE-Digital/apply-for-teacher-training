module CandidateInterface
  class Degrees::YearController < CandidateInterfaceController
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

      if @degree.update_year(current_application)
        redirect_to candidate_interface_degrees_review_path
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
        :award_year,
      ).transform_values(&:strip)
    end
  end
end
