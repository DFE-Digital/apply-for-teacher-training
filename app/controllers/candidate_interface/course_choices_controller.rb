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

  private

    def application_choice_params
      params.fetch(:candidate_interface_course_chosen_form, {}).permit(:choice)
    end
  end
end
