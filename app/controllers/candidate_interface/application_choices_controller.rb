module CandidateInterface
  class ApplicationChoicesController < CandidateInterfaceController
    before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
    before_action CarryOverFilter

    before_action SubmissionPermissionFilter, only: %i[submit confirm_destroy destroy]
    before_action :redirect_to_your_applications_if_submitted, only: %i[submit confirm_destroy destroy]

    # GET /candidate/application/choices(/:current_tab_name)
    def index
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)
      @application_choices = CandidateInterface::SortApplicationChoices.call(
        application_choices:
          current_application
            .application_choices
            .includes(:course, :site, :provider, :current_course, :current_course_option, :interviews)
            .includes(offer: :conditions),
      )
    end

    # POST /candidate/application/course-choices/:id/submit
    def submit
      @application_choice = application_choice
      @application_form = current_application
      @application_choice_submission = CandidateInterface::ApplicationChoiceSubmission.new(
        application_choice: @application_choice,
      )

      if @application_choice_submission.valid?
        submit_application_choice
      else
        render 'candidate_interface/course_choices/review_and_submit/show'
      end
    end

    # GET /candidate/application/course-choices/delete/:id
    def confirm_destroy
      @application_choice = application_choice
    end

    # DELETE /candidate/application/course-choices/delete/:id
    def destroy
      CandidateInterface::DeleteApplicationChoice.new(application_choice:).call

      redirect_to candidate_interface_application_choices_path
    end

  private

    def submit_application_choice
      CandidateInterface::SubmitApplicationChoice.new(@application_choice).call
      flash[:success] = t('application_form.submit_application_success.title')

      if FeatureFlag.active?(:candidate_preferences) && current_candidate.published_preferences.blank?
        redirect_to candidate_interface_share_details_path
      else
        redirect_to candidate_interface_application_choices_path
      end
    end

    def application_choice
      current_application
        .application_choices
        .find(params[:id])
    end
  end
end
