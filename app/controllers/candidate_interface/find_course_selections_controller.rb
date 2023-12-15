module CandidateInterface
  class FindCourseSelectionsController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    def confirm_selection
      redirect_to candidate_interface_application_form_path and return unless CycleTimetable.can_add_course_choice?(current_application)

      course = Course.find(params[:course_id])
      @course_selection_form = CourseSelectionForm.new(course)
    end

    def complete_selection
      course = Course.find(params[:course_id])

      course_selection = CourseSelectionForm.new(course, course_selection_params[:confirm])
      if !course_selection.confirm || current_application.contains_course?(course)
        redirect_to candidate_interface_course_choices_review_path
        return
      end

      if CourseOption.where(course_id: course.id).one?
        course_option = CourseOption.where(course_id: course.id).first
        pick_site_for_course(course_option.id)
      end
    end

  private

    def pick_site_for_course(course_option_id)
      pick_site = PickSiteForm.new(
        application_form: current_application,
        course_option_id:,
      )

      unless pick_site.save
        flash[:warning] = pick_site.errors.full_messages.first
      end

      if current_application.application_choices.any?
        redirect_to candidate_interface_course_choices_review_path
      else
        redirect_to candidate_interface_course_choices_choose_path
      end
    end

    def course_selection_params
      params.fetch(:candidate_interface_course_selection_form, {}).permit(:confirm)
    end
  end
end
