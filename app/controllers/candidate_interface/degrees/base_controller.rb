module CandidateInterface
  class Degrees::BaseController < CandidateInterfaceController
    def index
      @application_form = current_candidate.current_application
    end

    def new
      @degree = DegreesForm.new
    end

    def create
      @degree = DegreesForm.new(degrees_params)
      application_form = current_candidate.current_application

      if @degree.save_base(application_form)
        redirect_to candidate_interface_degrees_path
      else
        render :new
      end
    end

  private

    def degrees_params
      params.require(:candidate_interface_degrees_form).permit(
        :qualification_type, :subject, :institution_name, :grade, :other_grade,
        :predicted_grade, :award_year
      )
    end
  end
end
