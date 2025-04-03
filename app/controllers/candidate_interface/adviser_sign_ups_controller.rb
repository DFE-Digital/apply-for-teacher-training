module CandidateInterface
  class AdviserSignUpsController < CandidateInterfaceController
    before_action :render_404_unless_available

    def show
      @adviser_sign_up_form = Adviser::SignUpForm.build_from_hash(application_form, params[:preferred_teaching_subject_id])
    end

    def new
      @adviser_sign_up_form = Adviser::SignUpForm.build_from_hash(application_form, params[:preferred_teaching_subject_id])
    end

    def continue
      @adviser_sign_up_form = Adviser::SignUpForm.new(adviser_sign_up_params.merge(application_form:))

      if @adviser_sign_up_form.valid?
        redirect_to candidate_interface_adviser_sign_up_path(application_form.id, preferred_teaching_subject_id: @adviser_sign_up_form.preferred_teaching_subject_id)
      else
        track_validation_error(@adviser_sign_up_form)
        render :new
      end
    end

    def create
      @adviser_sign_up_form = Adviser::SignUpForm.new(adviser_sign_up_params.merge(application_form:))

      @adviser_sign_up_form.save
      flash[:success] = t('application_form.adviser_sign_up_form.flash.success')
      track_adviser_sign_up
      redirect_to candidate_interface_details_path
    end

  private

    def track_adviser_sign_up
      Adviser::Tracking.new(current_user, request).candidate_signed_up_for_adviser
    end

    def application_form
      current_candidate.current_application
    end

    def adviser_sign_up_params
      params
        .fetch(:adviser_sign_up_form, {})
        .permit(:preferred_teaching_subject_id)
    end

    def render_404_unless_available
      render_404 unless application_form.eligible_to_sign_up_for_a_teaching_training_adviser?
    end
  end
end
