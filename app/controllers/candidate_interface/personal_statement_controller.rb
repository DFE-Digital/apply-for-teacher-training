module CandidateInterface
  class PersonalStatementController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted, :render_application_feedback_component

    def edit
      @becoming_a_teacher_form = BecomingATeacherForm.build_from_application(
        current_application,
      )
    end

    def update
      @becoming_a_teacher_form = BecomingATeacherForm.new(becoming_a_teacher_params)

      if @becoming_a_teacher_form.save(current_application)
        current_application.update!(becoming_a_teacher_completed: false)

        redirect_to candidate_interface_becoming_a_teacher_show_path
      else
        track_validation_error(@becoming_a_teacher_form)
        render :edit
      end
    end

    def show
      @application_form = current_application
    end

    def complete
      current_application.update!(application_form_params)

      redirect_to candidate_interface_application_form_path
    end

  private

    def becoming_a_teacher_params
      strip_whitespace params.require(:candidate_interface_becoming_a_teacher_form).permit(
        :becoming_a_teacher,
      )
    end

    def application_form_params
      strip_whitespace params.require(:application_form).permit(:becoming_a_teacher_completed)
    end
  end
end
