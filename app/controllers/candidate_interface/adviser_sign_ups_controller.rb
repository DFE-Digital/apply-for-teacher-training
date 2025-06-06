module CandidateInterface
  class AdviserSignUpsController < CandidateInterfaceController
    before_action :render_404_unless_available

    def show
      @adviser_interruption_form = CandidateInterface::AdviserInterruptionForm.new({ application_form:, proceed_to_request_adviser: 'yes' })
      @adviser_sign_up_form = Adviser::SignUpForm.new({
        application_form:,
        preferred_teaching_subject_id: @adviser_interruption_form.prefill_preferred_teaching_subject_id,
      })
    end

    def new
      @adviser_sign_up_form = Adviser::SignUpForm.new({ application_form:, preferred_teaching_subject_id: params[:preferred_teaching_subject_id] })
      @back_link = back_link_data
    end

    def create
      @adviser_sign_up_form = Adviser::SignUpForm.new(adviser_sign_up_params.merge(application_form:))

      if @adviser_sign_up_form.save
        flash[:success] = t('.create.flash.success')
        track_adviser_sign_up
        redirect_to candidate_interface_details_path
      else
        track_validation_error(@adviser_sign_up_form)
        @back_link = back_link_data
        render :new
      end
    end

  private

    def back_link_data
      if params[:return_to] == 'interruption'
        { path: candidate_interface_adviser_sign_ups_interruption_path, text: t('.back') }
      else
        { path: candidate_interface_details_path, text: t('.back_to_details') }
      end
    end

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
      render_404 unless FeatureFlag.active?(:adviser_sign_up) && application_form.eligible_to_sign_up_for_a_teaching_training_adviser?
    end
  end
end
