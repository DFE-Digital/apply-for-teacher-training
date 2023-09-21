module CandidateInterface
  class SubjectKnowledgeController < SectionController
    before_action :redirect_to_dashboard_if_submitted, :render_application_feedback_component, :redirect_to_personal_statement_if_on_the_new_personal_statement

    def show
      @application_form = current_application
      @subject_knowledge_form = SubjectKnowledgeForm.build_from_application(
        current_application,
      )
      @section_complete_form = SectionCompleteForm.new(completed: current_application.subject_knowledge_completed)
    end

    def new
      @subject_knowledge_form = SubjectKnowledgeForm.new
      @course_names = chosen_course_names
    end

    def edit
      @subject_knowledge_form = SubjectKnowledgeForm.build_from_application(
        current_application,
      )
      @course_names = chosen_course_names
      @return_to = return_to_after_edit(default: candidate_interface_subject_knowledge_show_path)
    end

    def create
      @subject_knowledge_form = SubjectKnowledgeForm.new(subject_knowledge_params)

      if @subject_knowledge_form.save(current_application)
        if @subject_knowledge_form.blank?
          redirect_to candidate_interface_application_form_path
        else
          redirect_to candidate_interface_subject_knowledge_show_path
        end
      else
        track_validation_error(@subject_knowledge_form)
        @course_names = chosen_course_names
        render :new
      end
    end

    def update
      @subject_knowledge_form = SubjectKnowledgeForm.new(subject_knowledge_params)
      @return_to = return_to_after_edit(default: candidate_interface_subject_knowledge_show_path)

      @subject_knowledge_form.save(current_application)

      if @subject_knowledge_form.invalid?
        set_section_to_incomplete_if_completed
      end

      if @subject_knowledge_form.blank?
        redirect_to candidate_interface_application_form_path
      else
        redirect_to @return_to[:back_path]
      end
    end

    def complete
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(section_complete_form_params)

      if @section_complete_form.save(current_application, :subject_knowledge_completed)
        redirect_to candidate_interface_application_form_path
      else
        track_validation_error(@section_complete_form)
        @subject_knowledge_form = SubjectKnowledgeForm.build_from_application(
          current_application,
        )
        render :show
      end
    end

  private

    def set_section_to_incomplete_if_completed
      if current_application.subject_knowledge_completed?
        current_application.update!(subject_knowledge_completed: false)
      end
    end

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

    def redirect_to_personal_statement_if_on_the_new_personal_statement
      redirect_to candidate_interface_becoming_a_teacher_show_path if current_application.single_personal_statement_application?
    end
  end
end
