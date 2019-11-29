module CandidateInterface
  class CourseChoicesController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    def index
      @course_choices = current_candidate.current_application.application_choices
      if @course_choices.count < 1
        render :index
      else
        redirect_to candidate_interface_course_choices_review_path
      end
    end

    def have_you_chosen
      @choice_form = CandidateInterface::CourseChosenForm.new
    end

    def make_choice
      @choice_form = CandidateInterface::CourseChosenForm.new(application_choice_params)

      if !@choice_form.valid?
        render :have_you_chosen
      elsif @choice_form.chosen_a_course?
        redirect_to candidate_interface_course_choices_provider_path
      else
        redirect_to 'https://find-postgraduate-teacher-training.education.gov.uk'
      end
    end

    def options_for_provider
      @pick_provider = PickProviderForm.new
    end

    def pick_provider
      @pick_provider = PickProviderForm.new(code: params.dig(:candidate_interface_pick_provider_form, :code))

      if !@pick_provider.valid?
        render :options_for_provider
      elsif @pick_provider.other?
        redirect_to candidate_interface_course_choices_on_ucas_path
      else
        redirect_to candidate_interface_course_choices_course_path(provider_code: @pick_provider.code)
      end
    end

    def ucas; end

    def options_for_course
      @pick_course = PickCourseForm.new(
        provider_code: params.fetch(:provider_code),
        application_form: current_application,
      )
    end

    def pick_course
      @pick_course = PickCourseForm.new(
        provider_code: params.fetch(:provider_code),
        code: params.dig(:candidate_interface_pick_course_form, :code),
        application_form: current_application,
      )

      if !@pick_course.valid?
        render :options_for_course
      elsif @pick_course.other?
        redirect_to candidate_interface_course_choices_on_ucas_path
      else
        redirect_to candidate_interface_course_choices_site_path(provider_code: @pick_course.provider_code, course_code: @pick_course.code)
      end
    end

    def options_for_site
      @pick_site = PickSiteForm.new(
        provider_code: params.fetch(:provider_code),
        course_code: params.fetch(:course_code),
      )
    end

    def pick_site
      @pick_site = PickSiteForm.new(
        application_form: current_application,
        provider_code: params.fetch(:provider_code),
        course_code: params.fetch(:course_code),
        course_option_id: params.dig(:candidate_interface_pick_site_form, :course_option_id),
      )

      if @pick_site.save
        redirect_to candidate_interface_course_choices_index_path
      else
        render :options_for_site
      end
    end

    def review
      @application_form = current_application
      @course_choices = current_candidate.current_application.application_choices
    end

    def confirm_destroy
      @course_choice = current_candidate.current_application.application_choices.find(params[:id])
    end

    def destroy
      current_application
        .application_choices
        .find(current_course_choice_id)
        .destroy!

      redirect_to candidate_interface_course_choices_index_path
    end

    def complete
      @application_form = current_application

      if @application_form.update(application_form_params)
        redirect_to candidate_interface_application_form_path
      else
        @course_choices = current_candidate.current_application.application_choices
        render :review
      end
    end

  private

    def current_course_choice_id
      params.permit(:id)[:id]
    end

    def application_form_params
      params.require(:application_form).permit(:course_choices_completed)
    end

    def application_choice_params
      params.fetch(:candidate_interface_course_chosen_form, {}).permit(:choice)
    end
  end
end
