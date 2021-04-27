module CandidateInterface
  class SubjectKnowledgeController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted, :render_application_feedback_component

    def edit
      @subject_knowledge_form = SubjectKnowledgeForm.build_from_application(
        current_application,
      )
      @course_names = chosen_course_names
    end

    def update
      @subject_knowledge_form = SubjectKnowledgeForm.new(subject_knowledge_params)

      if @subject_knowledge_form.save(current_application)
        current_application.update!(subject_knowledge_completed: false)

        redirect_to candidate_interface_subject_knowledge_show_path
      else
        track_validation_error(@subject_knowledge_form)
        @course_names = chosen_course_names
        render :edit
      end
    end

    def show
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(completed: current_application.subject_knowledge_completed)
    end

    def complete
      @section_complete_form = SectionCompleteForm.new(section_complete_form_params)

      if @section_complete_form.save(current_application, :subject_knowledge_completed)
        redirect_to candidate_interface_application_form_path
      else
        track_validation_error(@section_complete_form)
        render :show
      end
    end

  private

    def subject_knowledge_params
      strip_whitespace params.require(:candidate_interface_subject_knowledge_form).permit(
        :subject_knowledge,
      )
    end

    def chosen_course_names
      current_application.application_choices.map(&:course).map(&:name_and_code)
    end

    def section_complete_form_params
      strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
    end
  end
end
