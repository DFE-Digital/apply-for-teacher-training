module CandidateInterface
  class Degrees::BaseController < CandidateInterfaceController
    def new
      @degree = DegreeForm.new

      render_new
    end

    def create
      @degree = DegreeForm.new(degree_params)
      application_form = current_candidate.current_application

      if @degree.save(application_form)
        redirect_to candidate_interface_degrees_review_path
      else
        render_new
      end
    end

    def edit
      application_form = current_candidate.current_application
      @degree = DegreeForm.build_from_application(application_form, degree_id_params)
    end

    def update
      @degree = DegreeForm.new(degree_params)
      application_form = current_candidate.current_application

      if @degree.update(application_form)
        redirect_to candidate_interface_degrees_review_path
      else
        render_new
      end
    end

  private

    def degree_id_params
      params.permit(:id)[:id]
    end

    def degree_params
      params.require(:candidate_interface_degree_form).permit(
        :id, :qualification_type, :subject, :institution_name, :grade, :other_grade,
        :predicted_grade, :award_year
      )
    end

    def render_new
      degrees = DegreeForm.build_all_from_application(current_candidate.current_application)

      if degrees.count.zero?
        render :new_undergraduate
      else
        render :new_another
      end
    end
  end
end
