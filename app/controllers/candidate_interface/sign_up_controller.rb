module CandidateInterface
  class SignUpController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!
    before_action :redirect_to_application_if_signed_in
    before_action :show_pilot_holding_page_if_not_open

    def new
      @sign_up_form = CandidateInterface::SignUpForm.new
    end

    def create
      @sign_up_form = CandidateInterface::SignUpForm.new(candidate_sign_up_form_params)

      if @sign_up_form.existing_candidate?
        MagicLinkSignIn.call(candidate: @sign_up_form.candidate)
        add_identity_to_log @sign_up_form.candidate.id
        redirect_to candidate_interface_check_email_sign_up_path
      elsif @sign_up_form.save
        MagicLinkSignUp.call(candidate: @sign_up_form.candidate)
        add_identity_to_log @sign_up_form.candidate.id
        redirect_to candidate_interface_check_email_sign_up_path
      else
        render :new
      end
    end

    def show; end

  private

    def candidate_sign_up_form_params
      params.require(:candidate_interface_sign_up_form).permit(:email_address, :accept_ts_and_cs).merge(course_from_find_id: course_id)
    end

    def course_id
      @provider = Provider.find_by(code: params[:providerCode])
      @course = @provider.courses.find_by(code: params[:courseCode]) if @provider.present?
      @course.id if @course.present?
    end
  end
end
