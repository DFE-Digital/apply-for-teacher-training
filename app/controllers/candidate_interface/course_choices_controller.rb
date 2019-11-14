module CandidateInterface
  class CourseChoicesController < CandidateInterfaceController
    def index
      @course_choices = current_candidate.current_application.application_choices
    end

    def have_you_chosen
      @choice = current_candidate.current_application.application_choices.new
    end

    def make_choice
      if application_choice_params[:choice] == 'yes'
        redirect_to candidate_interface_course_choices_provider_path
      else
        redirect_to 'https://find-postgraduate-teacher-training.education.gov.uk'
      end
    end

    def options_for_provider
      @providers = Provider.all
    end

    def pick_provider
      redirect_to candidate_interface_course_choices_course_path(provider_code: provider_params[:code])
    end

    def options_for_course
      @courses = Provider
        .find_by(code: params[:provider_code])
        .courses
        .where(exposed_in_find: true)
    end

    def pick_course
      redirect_to candidate_interface_course_choices_site_path(provider_code: params[:provider_code], course_code: course_params[:code])
    end

    def options_for_site
      provider = Provider.find_by(code: params[:provider_code])
      course = provider.courses.find_by(code: params[:course_code])
      @options = CourseOption.where(course_id: course.id)
    end

    def pick_site
      # TODO: add better validation
      redirect_back(fallback_location: root_path) && return unless params[:course_option]

      current_candidate.current_application.application_choices.create!(
        course_option: CourseOption.find(course_option_params[:id]),
      )

      redirect_to candidate_interface_course_choices_index_path
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

  private

    def current_course_choice_id
      params.permit(:id)[:id]
    end

    def application_choice_params
      params.require(:application_choice).permit(:choice)
    end

    def provider_params
      params.require(:provider).permit(:code)
    end

    def course_params
      params.require(:course).permit(:code)
    end

    def course_option_params
      params.require(:course_option).permit(:id)
    end
  end
end
