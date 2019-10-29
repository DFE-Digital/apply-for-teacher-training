module CandidateInterface
  class Degrees::BaseController < CandidateInterfaceController
    def new
      @degree = DegreesForm.new
    end

    def create
      @degree = DegreesForm.new(degrees_params)
      application_form = current_candidate.current_application

      render :new unless @degree.save_base(application_form)
    end

  private

    def degrees_params
      params.require(:candidate_interface_degrees_form).permit(
        :qualification_type, :subject, :institution_name
      )
    end
  end
end
