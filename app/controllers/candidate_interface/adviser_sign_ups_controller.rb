module CandidateInterface
  class AdviserSignUpsController < CandidateInterfaceController
    before_action :set_adviser_sign_up
    # before_action :render_404_unless_available

    def show; end

    def new; end

    def create
      if @adviser_sign_up.save
        track_adviser_sign_up

        redirect_to candidate_interface_adviser_sign_up_path(
          @adviser_sign_up.application_form.id,
          preferred_teaching_subject_id: @adviser_sign_up.preferred_teaching_subject_id,
        )
      else
        track_validation_error(@adviser_sign_up)
        render :new
      end
    end

    def submit
      redirect_to candidate_interface_details_path
      flash[:success] = t('application_form.adviser_sign_up.flash.success')
    end

  private

    def track_adviser_sign_up
      Adviser::Tracking.new(current_user, request).candidate_signed_up_for_adviser
    end

    def set_adviser_sign_up
      @adviser_sign_up = if params[:preferred_teaching_subject_id].present?
                           Adviser::SignUp.build_from_hash(application_form, params[:preferred_teaching_subject_id])
                         else
                           Adviser::SignUp.new(adviser_sign_up_params.merge(application_form:))
                         end
    end

    def application_form
      current_candidate.current_application
    end

    def adviser_sign_up_params
      params
        .fetch(:adviser_sign_up, {})
        .permit(:preferred_teaching_subject_id)
    end

    def render_404_unless_available
      render_404 unless application_form.eligible_to_sign_up_for_a_teaching_training_adviser?
    end
  end
end
