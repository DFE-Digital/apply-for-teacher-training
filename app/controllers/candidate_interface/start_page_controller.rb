module CandidateInterface
  class StartPageController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!

    def show; end

    def eligibility
      @eligibility_form = EligibilityForm.new
    end

    def determine_eligibility
      @eligibility_form = EligibilityForm.new(eligibility_params)

      if !@eligibility_form.valid?
        render :eligibility
      elsif @eligibility_form.eligible_to_use_dfe_apply?
        redirect_to candidate_interface_sign_up_path
      else
        render :not_eligible
      end
    end

    def eligibility_params
      params.fetch(:candidate_interface_eligibility_form, {}).permit(:eligible_citizen, :eligible_qualifications)
    end
  end
end
