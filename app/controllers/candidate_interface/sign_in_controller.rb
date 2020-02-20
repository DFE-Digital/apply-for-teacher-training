module CandidateInterface
  class SignInController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!
    before_action :redirect_to_application_if_signed_in, except: %i[authenticate interstitial]

    def new
      if FeatureFlag.active?('improved_expired_token_flow') && params[:u]
        redirect_to candidate_interface_expired_sign_in_path(u: params[:u])
      else
        @candidate = Candidate.new
      end
    end

    def interstitial
      if more_reference_needed? && FeatureFlag.active?('show_new_referee_needed')
        redirect_to candidate_interface_additional_referee_path
      else
        redirect_to candidate_interface_application_form_path
      end
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
      token_not_expired = FindCandidateByToken.token_not_expired?(candidate)

      if candidate.nil? && FeatureFlag.active?('improved_expired_token_flow') && params[:u]
        candidate_id = Encryptor.decrypt(params[:u])
        candidate = Candidate.find(candidate_id) if candidate_id
      end

      if candidate.nil?
        redirect_to action: :new
      elsif token_not_expired
        flash[:success] = t('apply_from_find.account_created_message') if candidate.last_signed_in_at.nil?

        sign_in(candidate, scope: :candidate)
        add_identity_to_log candidate.id
        candidate.update!(last_signed_in_at: Time.zone.now)

        course = candidate.course_from_find

        service = ExistingCandidateAuthentication.new(candidate: candidate)
        service.execute

        if service.candidate_does_not_have_a_course_from_find || service.candidate_has_submitted_application
          redirect_to candidate_interface_interstitial_path
        elsif service.candidate_has_already_selected_the_course
          flash[:warning] = "You have already selected #{course.name_and_code}."
          redirect_to candidate_interface_course_choices_review_path
        elsif service.candidate_has_new_course_added
          redirect_to candidate_interface_course_choices_review_path
        elsif service.candidate_should_choose_site
          redirect_to candidate_interface_course_choices_site_path(course.provider.id, course.id)
        elsif service.candidate_already_has_3_courses
          flash[:warning] = "You cannot have more than 3 course choices. You must delete a choice if you want to apply to #{course.name_and_code}."
          redirect_to candidate_interface_course_choices_review_path
        end
      else
        # rubocop:disable Style/IfInsideElse
        if FeatureFlag.active?('improved_expired_token_flow')
          encrypted_candidate_id = Encryptor.encrypt(candidate.id)
          redirect_to candidate_interface_expired_sign_in_path(u: encrypted_candidate_id)
        else
          redirect_to action: :new
        end
        # rubocop:enable Style/IfInsideElse
      end
    end

    def expired
      raise unless FeatureFlag.active?('improved_expired_token_flow')

      if params[:u].blank?
        redirect_to candidate_interface_sign_in_path
      end
    end

    def create_from_expired_token
      render_404 unless FeatureFlag.active?('improved_expired_token_flow')

      candidate_id = Encryptor.decrypt(params.fetch(:u))
      if candidate_id
        candidate = Candidate.find(candidate_id)
        MagicLinkSignIn.call(candidate: candidate)
        add_identity_to_log candidate.id
        redirect_to candidate_interface_check_email_sign_in_path
      else
        render 'errors/not_found', status: :forbidden
      end
    end

  private

    def candidate_params
      params.require(:candidate).permit(:email_address)
    end
  end
end
