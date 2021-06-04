module CandidateInterface
  class SignInCandidate
    attr_reader :controller, :email

    def initialize(email, controller)
      @controller = controller
      @email = email
    end

    delegate(
      :params,
      :redirect_to,
      :render,
      :candidate_interface_check_email_sign_in_path,
      to: :controller,
    )

    def call
      candidate = Candidate.for_email email

      if candidate.persisted?
        update_course_from_find(candidate)
        CandidateInterface::RequestMagicLink.for_sign_in(candidate: candidate)
        controller.set_user_context(candidate.id)
        redirect_to candidate_interface_check_email_sign_in_path
      elsif candidate.valid?
        AuthenticationMailer.sign_in_without_account_email(to: candidate.email_address).deliver_now
        redirect_to candidate_interface_check_email_sign_in_path
      else
        controller.track_validation_error(candidate)
        render 'candidate_interface/sign_in/new', locals: { candidate: candidate }
      end
    end

  private

    def update_course_from_find(candidate)
      return nil if provider.blank?

      course = provider
        .courses
        .current_cycle
        .find_by(code: params[:courseCode])

      candidate.update!(course_from_find_id: course.id) if course.present?
    end

    def provider
      @_provider ||= Provider.find_by(code: params[:providerCode])
    end
  end
end
