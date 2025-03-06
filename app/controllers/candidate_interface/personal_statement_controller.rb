module CandidateInterface
  class PersonalStatementController < SectionController
    before_action :render_application_feedback_component
    def show
      @application_form = current_application
      @becoming_a_teacher_form = BecomingATeacherForm.build_from_application(
        current_application,
      )
      @section_complete_form = SectionCompleteForm.new(completed: current_application.becoming_a_teacher_completed)
    end

    def new
      @becoming_a_teacher_form = BecomingATeacherForm.build_from_application(current_application)
    end

    def edit
      @becoming_a_teacher_form = BecomingATeacherForm.build_from_application(
        current_application,
      )
      @return_to = return_to_after_edit(default: candidate_interface_becoming_a_teacher_show_path)
    end

    def create
      @becoming_a_teacher_form = BecomingATeacherForm.build_from_params(becoming_a_teacher_params)

      if @becoming_a_teacher_form.save(current_application)
        if @becoming_a_teacher_form.blank?
          redirect_to candidate_interface_details_path
        else
          redirect_to candidate_interface_becoming_a_teacher_show_path
        end
      else
        track_validation_error(@becoming_a_teacher_form)
        render :new
      end
    end

    def update
      @becoming_a_teacher_form = BecomingATeacherForm.build_from_params(becoming_a_teacher_params)
      @return_to = return_to_after_edit(default: candidate_interface_becoming_a_teacher_show_path)

      unless @becoming_a_teacher_form.valid?
        set_section_to_incomplete_if_completed
      end

      if @becoming_a_teacher_form.save(current_application)
        if @becoming_a_teacher_form.blank?
          redirect_to candidate_interface_details_path
        else
          redirect_to @return_to[:back_path]
        end
      else
        track_validation_error(@becoming_a_teacher_form)
        render :edit
      end
    end

    def complete
      @becoming_a_teacher_form = BecomingATeacherForm.build_from_application(
        current_application,
      )
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(form_params)

      if @section_complete_form.save(current_application, :becoming_a_teacher_completed)
        redirect_to_candidate_root
      else
        track_validation_error(@section_complete_form)
        render :show
      end
    end

  private

    def set_section_to_incomplete_if_completed
      if current_application.becoming_a_teacher_completed?
        current_application.update!(becoming_a_teacher_completed: false)
      end
    end

    def becoming_a_teacher_params
      strip_whitespace params.expect(
        candidate_interface_becoming_a_teacher_form: [:becoming_a_teacher],
      )
    end

    def form_params
      strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
    end
  end
end
