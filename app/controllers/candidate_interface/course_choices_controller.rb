module CandidateInterface
  class CourseChoicesController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    def have_you_chosen
      @choice_form = CandidateInterface::CourseChosenForm.new
    end

    def make_choice
      @choice_form = CandidateInterface::CourseChosenForm.new(application_choice_params)
      render :have_you_chosen and return unless @choice_form.valid?

      if @choice_form.chosen_a_course?
        redirect_to candidate_interface_course_choices_provider_path
      else
        redirect_to candidate_interface_go_to_find_path
      end
    end

    def go_to_find; end

    def ucas_no_courses
      @provider = Provider.find_by!(id: params[:provider_id])
    end

    def ucas_with_course
      @provider = Provider.find_by!(id: params[:provider_id])
      @course = Course.find_by!(id: params[:course_id])
    end

    def full
      @course = Course.find(params[:course_id])
    end

    def add_another_course
      @additional_courses_allowed = 3 - current_candidate.current_application.application_choices.count
      @add_another_course = AddAnotherCourseForm.new
    end

    def add_another_course_selection
      @additional_courses_allowed = 3 - current_candidate.current_application.application_choices.count
      @add_another_course = AddAnotherCourseForm.new(add_another_course_params)
      return render :add_another_course unless @add_another_course.valid?

      if @add_another_course.add_another_course?
        redirect_to candidate_interface_course_choices_choose_path
      else
        redirect_to candidate_interface_course_choices_index_path
      end
    end

  private

    def application_choice_params
      params.fetch(:candidate_interface_course_chosen_form, {}).permit(:choice)
    end

    def add_another_course_params
      params.fetch(:candidate_interface_add_another_course_form, {}).permit(:add_another_course)
    end
  end
end
