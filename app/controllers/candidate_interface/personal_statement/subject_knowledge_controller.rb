module CandidateInterface
  class PersonalStatement::SubjectKnowledgeController < CandidateInterfaceController
    def edit
      @subject_knowledge_form = SubjectKnowledgeForm.build_from_application(
        current_application,
      )
    end

    def update
      @subject_knowledge_form = SubjectKnowledgeForm.new(subject_knowledge_params)

      if @subject_knowledge_form.save(current_application)
        render :show
      else
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
  end
end
