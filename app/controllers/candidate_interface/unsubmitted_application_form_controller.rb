module CandidateInterface
  class UnsubmittedApplicationFormController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    before_action :redirect_to_application_if_between_cycles, except: %w[show review]
    before_action :render_error_if_continuous_applications_active, only: %w[submit]
    before_action :redirect_to_new_continuous_applications_if_active, only: %w[show]
    before_action :redirect_to_carry_over, except: %w[review]
    before_action :set_unavailable_courses, only: %w[review submit_show]

    def show
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)
      @adviser_sign_up = Adviser::SignUp.new(current_application)
      @application_cache_key = CacheKey.generate(@application_form_presenter.cache_key_with_version)

      track_adviser_offering if @adviser_sign_up.available?
    end

    def review
      redirect_to candidate_interface_application_complete_path if current_application.submitted?
      @application_form = current_application
    end

    def submit_show
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)
      @application_form = @application_form_presenter.application_form

      unless @application_form_presenter.ready_to_submit?
        @incomplete_sections = @application_form_presenter.incomplete_sections
        @application_choice_errors = @application_form_presenter.application_choice_errors
        @reference_section_errors = @application_form_presenter.reference_section_errors

        render 'candidate_interface/unsubmitted_application_form/review' and return
      end
    end

    def submit
      SubmitApplication.new(current_application).call

      if current_application.feedback_form_complete?
        flash[:success] = t('application_form.submit_application_success.title')
        redirect_to candidate_interface_application_complete_path
      else
        redirect_to candidate_interface_feedback_form_path
      end
    end

  private

    def track_adviser_offering
      Adviser::Tracking.new(current_user, request).candidate_offered_adviser
    end

    def redirect_to_application_if_between_cycles
      if CycleTimetable.between_cycles?(current_application.phase)
        redirect_to candidate_interface_application_form_path and return false
      end

      true
    end

    def redirect_to_carry_over
      return unless current_application.carry_over?

      redirect_to candidate_interface_start_carry_over_path
    end

    def set_unavailable_courses
      @courses_not_yet_open = GetCoursesNotYetOpenForApplication.new(application_form: current_application).call
      @full_courses = GetFullCoursesForApplication.new(application_form: current_application).call
    end
  end
end
