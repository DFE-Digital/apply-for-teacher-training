module CandidateInterface
  class Degrees::BaseController < CandidateInterfaceController
    def new
      @degree = DegreeForm.new

      render_new
    end

    def create
      @degree = DegreeForm.new(degree_params)

      if @degree.save(current_application)
        redirect_to candidate_interface_degrees_review_path
      else
        render_new
      end
    end

    def edit
      @degree = DegreeForm.build_from_application(current_application, current_degree_id)
    end

    def update
      @degree = DegreeForm.new(degree_params)

      if @degree.update(current_application)
        redirect_to candidate_interface_degrees_review_path
      else
        render_new
      end
    end

  private

    def current_degree_id
      params.permit(:id)[:id]
    end

    def degree_params
      params.require(:candidate_interface_degree_form).permit(
        :id, :qualification_type, :subject, :institution_name, :grade, :other_grade,
        :predicted_grade, :award_year
      )
    end

    def render_new
      degrees = DegreeForm.build_all_from_application(current_application)

      if degrees.count.zero?
        render :new_undergraduate
      else
        render :new_another
      end
    end
  end
end
