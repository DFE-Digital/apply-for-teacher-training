module CandidateInterface
  class SubjectKnowledgeReviewComponent < ViewComponent::Base
    def initialize(application_form:, editable: true, missing_error: false, submitting_application: false, return_to_application_review: false)
      @application_form = application_form
      @subject_knowledge_form = CandidateInterface::SubjectKnowledgeForm.build_from_application(
        @application_form,
      )
      @editable = editable
      @missing_error = missing_error
      @submitting_application = submitting_application
      @return_to_application_review = return_to_application_review
    end

    def subject_knowledge_form_rows
      [subject_knowledge_form_row]
    end

    def show_missing_banner?
      !@application_form.subject_knowledge_completed && @editable if @submitting_application
    end

    def review_needed?
      @application_form.review_pending?(:subject_knowledge)
    end

  private

    attr_reader :application_form

    def subject_knowledge_form_row
      {
        key: t('application_form.personal_statement.subject_knowledge.key'),
        value: @subject_knowledge_form.subject_knowledge,
        action: t('application_form.personal_statement.subject_knowledge.change_action'),
        change_path: candidate_interface_edit_subject_knowledge_path(return_to_params),
        data_qa: 'subject-knowledge',
      }
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end
  end
end
