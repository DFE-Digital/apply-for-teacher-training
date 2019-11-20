module CandidateInterface
  class PersonalStatement::BecomingATeacherController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def edit
      @becoming_a_teacher_form = BecomingATeacherForm.build_from_application(
        current_application,
      )
    end

    def update
      @becoming_a_teacher_form = BecomingATeacherForm.new(becoming_a_teacher_params)

      if @becoming_a_teacher_form.save(current_application)
        render :show
      else
        render :edit
      end
    end

    def show
      @becoming_a_teacher_form = current_application
    end

  private

    def becoming_a_teacher_params
      params.require(:candidate_interface_becoming_a_teacher_form).permit(
        :becoming_a_teacher,
      )
    end
  end
end
