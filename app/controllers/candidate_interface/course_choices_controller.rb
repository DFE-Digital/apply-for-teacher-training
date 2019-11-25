module CandidateInterface
  class CourseChoicesController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted, except: :withdraw

    def index
      @application_form = current_application
      @course_choices = current_candidate.current_application.application_choices
      @page_title = if @course_choices.count < 1
                      I18n.t!('page_titles.choosing_courses')
                    else
                      I18n.t!('page_titles.course_choices')
                    end
    end

    def have_you_chosen
      @choice_form = CandidateInterface::CourseChosenForm.new
    end

    def make_choice
      @choice_form = CandidateInterface::CourseChosenForm.new(application_choice_params)

      if @choice_form.valid?
        if @choice_form.choice == 'yes'
          redirect_to candidate_interface_course_choices_provider_path
        else
          redirect_to 'https://find-postgraduate-teacher-training.education.gov.uk'
        end
      else
        render :have_you_chosen
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
      @pick_course = PickCourseForm.new(provider_code: params.fetch(:provider_code))
    end

    def pick_course
      @pick_course = PickCourseForm.new(
        provider_code: params.fetch(:provider_code),
        code: params.dig(:candidate_interface_pick_course_form, :code),
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
      provider = Provider.find_by(code: params[:provider_code])
      course = provider.courses.find_by(code: params[:course_code])
      @options = CourseOption.where(course_id: course.id)
    end

    def pick_site
      # TODO: add better validation
      redirect_back(fallback_location: root_path) && return unless params[:course_option]

      @application_form = current_application
      @course_choices = @application_form.application_choices
      selected_courses = @course_choices.map(&:course)

      if selected_courses.include?(Course.find_by(code: params[:course_code]))
        @application_form.errors[:base] << 'You have already selected this course'
        render :index
      else
        @course_choices.create!(
          course_option: CourseOption.find(course_option_params[:id]),
        )
        redirect_to candidate_interface_course_choices_index_path
      end
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
        render :index
      end
    end

    def withdraw
      @course_choice = current_candidate.current_application.application_choices.find(params[:id])
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

    def course_option_params
      params.require(:course_option).permit(:id)
    end
  end
end
