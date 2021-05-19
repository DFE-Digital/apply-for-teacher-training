module CandidateInterface
  class PersonalStatementController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted, :render_application_feedback_component

    def new
      @becoming_a_teacher_form = BecomingATeacherForm.new
    end

    def create
      @becoming_a_teacher_form = BecomingATeacherForm.new(becoming_a_teacher_params)

      if @becoming_a_teacher_form.save(current_application)
        redirect_to candidate_interface_becoming_a_teacher_show_path
      else
        track_validation_error(@becoming_a_teacher_form)
        render :new
      end
    end

    def edit
      @becoming_a_teacher_form = BecomingATeacherForm.build_from_application(
        current_application,
      )
    end

    def update
      @becoming_a_teacher_form = BecomingATeacherForm.new(becoming_a_teacher_params)

      if @becoming_a_teacher_form.save(current_application)
        redirect_to candidate_interface_becoming_a_teacher_show_path
      else
        track_validation_error(@becoming_a_teacher_form)
        render :edit
      end
    end

    def show
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(completed: current_application.becoming_a_teacher_completed)
    end

    def complete
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(form_params)

      if @section_complete_form.save(current_application, :becoming_a_teacher_completed)
        redirect_to candidate_interface_application_form_path
      else
        track_validation_error(@section_complete_form)
        render :show
      end
    end

  private

    def becoming_a_teacher_params
      strip_whitespace params.require(:candidate_interface_becoming_a_teacher_form).permit(
        :becoming_a_teacher,
      )
    end

    def form_params
      strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
    end
  end
end
