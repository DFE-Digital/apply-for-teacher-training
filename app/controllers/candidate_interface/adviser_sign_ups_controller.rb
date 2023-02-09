module CandidateInterface
  class AdviserSignUpsController < CandidateInterfaceController
    before_action :set_adviser_sign_up
    before_action :render_404_unless_available

    def new; end

    def create
      if @adviser_sign_up.save
        flash[:success] = t('application_form.adviser_sign_up.flash.success')

        redirect_to candidate_interface_application_form_path
      else
        track_validation_error(@adviser_sign_up)
        render :new
      end
    end

  private

    def set_adviser_sign_up
      @adviser_sign_up = Adviser::SignUp.new(application_form, adviser_sign_up_params)
    end

    def application_form
      current_candidate.current_application
    end

    def adviser_sign_up_params
      params
        .fetch(:adviser_sign_up, {})
        .permit(:preferred_teaching_subject)
    end

    def render_404_unless_available
      render_404 unless @adviser_sign_up.available?
    end
  end
end
