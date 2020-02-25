module CandidateInterface
  class FindCourseSelectionsController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable
    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    def confirm_selection
      render_404 unless FeatureFlag.active?('you_selected_a_course_page')

      course = Course.find(params[:course_id])
      @course_selection_form = CourseSelectionForm.new(course)
    end

    def complete_selection
      render_404 unless FeatureFlag.active?('you_selected_a_course_page')

      course = Course.find(params[:course_id])

      course_selection = CourseSelectionForm.new(course, course_selection_params[:confirm])
      if !course_selection.confirm
        redirect_to candidate_interface_course_choices_index_path
        return
      end

      # TODO: refactor this into a service etc.?
      if CourseOption.where(course_id: course.id).one?
        course_option = CourseOption.where(course_id: course.id).first

        pick_site_for_course(course, course_option.id)
      else
        redirect_to candidate_interface_course_choices_site_path(
          provider_id: course.provider_id,
          course_id: course.id,
        )
      end
    end

  private

    def pick_site_for_course(course, course_option_id)
      pick_site = PickSiteForm.new(
        application_form: current_application,
        provider_id: course.provider_id,
        course_id: course.id,
        course_option_id: course_option_id,
      )

      if pick_site.save
        redirect_to candidate_interface_course_choices_index_path
      else
        render :options_for_site
      end
    end

    def course_selection_params
      params.fetch(:candidate_interface_course_selection_form, {}).permit(:confirm)
    end
  end
end
