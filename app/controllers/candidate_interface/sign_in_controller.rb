module CandidateInterface
  class SignInController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!
    before_action :redirect_to_application_if_signed_in, except: :authenticate

    def new
      @candidate = Candidate.new
    end

    def create
      @candidate = Candidate.for_email candidate_params[:email_address]

      if @candidate.persisted?
        MagicLinkSignIn.call(candidate: @candidate)
        add_identity_to_log @candidate.id
        redirect_to candidate_interface_check_email_sign_in_path
      elsif @candidate.valid?
        AuthenticationMailer.sign_in_without_account_email(to: @candidate.email_address).deliver_now
        redirect_to candidate_interface_check_email_sign_in_path
      else
        render :new
      end
    end

    def authenticate
      candidate = FindCandidateByToken.call(raw_token: params[:token])

      if candidate
        sign_in(candidate, scope: :candidate)
        add_identity_to_log candidate.id
        course_id = candidate.course_from_find_id
        if has_course_from_find?(candidate) && course_has_one_site?(course_id)
          add_application_choice(course_id, candidate)
          set_course_from_find_id_to_nil(candidate)

          redirect_to candidate_interface_course_choices_review_path
        elsif has_course_from_find?(candidate)
          course = Course.find(course_id)
          set_course_from_find_id_to_nil(candidate)

          redirect_to candidate_interface_course_choices_site_path(course.provider.code, course.code)
        else
          redirect_to candidate_interface_application_form_path
        end
      else
        redirect_to action: :new
      end
    end

  private

    def candidate_params
      params.require(:candidate).permit(:email_address)
    end

    def course_has_one_site?(course_id)
      CourseOption.where(course_id: course_id).one?
    end

    def add_application_choice(course_id, candidate)
      course_option = CourseOption.find_by!(course_id: course_id)
      new_application_choice = ApplicationChoice.new(course_option_id: course_option.id)
      candidate.current_application.application_choices << new_application_choice
    end

    def set_course_from_find_id_to_nil(candidate)
      candidate.update(course_from_find_id: nil)
    end

    def has_course_from_find?(candidate)
      candidate.course_from_find_id.present?
    end
  end
end
