module CandidateInterface
  class Degrees::BaseController < CandidateInterfaceController
    def new
      @degree = DegreesForm.new

      render_new
    end

    def create
      @degree = DegreesForm.new(degrees_params)
      application_form = current_candidate.current_application

      if @degree.save(application_form)
        redirect_to candidate_interface_degrees_review_path
      else
        render_new
      end
    end

    def edit
      application_form = current_candidate.current_application
      @degree = DegreesForm.build_from_application(application_form, degree_params[:id])
    end

    def update
      @degree = DegreesForm.new(degrees_params)
      application_form = current_candidate.current_application

      if @degree.update(application_form, degree_params[:id])
        redirect_to candidate_interface_degrees_review_path
      else
        render_new
      end
    end

  private

    def degree_params
      params.permit(:id)
    end

    def degrees_params
      params.require(:candidate_interface_degrees_form).permit(
        :qualification_type, :subject, :institution_name, :grade, :other_grade,
        :predicted_grade, :award_year
      )
    end

    def render_new
      degrees = DegreesForm.build_all_from_application(current_candidate.current_application)

      if degrees.count.zero?
        render :new_undergraduate
      else
        render :new_another
      end
    end
  end
end
