module CandidateInterface
  class PersonalStatement::SubjectKnowledgeController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def edit
      @subject_knowledge_form = SubjectKnowledgeForm.build_from_application(
        current_application,
      )
      @course_names = chosen_course_names
    end

    def update
      @subject_knowledge_form = SubjectKnowledgeForm.new(subject_knowledge_params)

      if @subject_knowledge_form.save(current_application)
        render :show
      else
        @course_names = chosen_course_names
        render :edit
      end
    end

    def show
      @subject_knowledge_form = current_application
    end

  private

    def subject_knowledge_params
      params.require(:candidate_interface_subject_knowledge_form).permit(
        :subject_knowledge,
      )
    end

    def chosen_course_names
      current_application.application_choices.map(&:course).map(&:name_and_code)
    end
  end
end
