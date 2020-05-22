module CandidateInterface
  class PersonalStatement::BecomingATeacherController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    after_action :complete_section, only: %i[update]

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
      params.require(:candidate_interface_becoming_a_teacher_form).permit(
        :becoming_a_teacher,
      )
        .transform_values(&:strip)
    end

    def application_form_params
      params.require(:application_form).permit(:becoming_a_teacher_completed)
        .transform_values(&:strip)
    end

    def complete_section
      presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)

      if presenter.becoming_a_teacher_completed? && !FeatureFlag.active?('mark_every_section_complete')
        current_application.update!(becoming_a_teacher_completed: true)
      end
    end
  end
end
