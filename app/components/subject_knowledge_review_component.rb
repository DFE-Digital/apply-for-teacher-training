class SubjectKnowledgeReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:, editable: true, missing_error: false)
    @application_form = application_form
    @subject_knowledge_form = CandidateInterface::SubjectKnowledgeForm.build_from_application(
      @application_form,
    )
    @editable = editable
    @missing_error = missing_error
  end

  def subject_knowledge_form_rows
    [subject_knowledge_form_row]
  end

  def show_missing_banner?
    !@subject_knowledge_form.valid? && @editable
  end

private

  attr_reader :application_form

  def subject_knowledge_form_row
    {
      key: t('application_form.personal_statement.subject_knowledge.key'),
      value: @subject_knowledge_form.subject_knowledge,
      action: t('application_form.personal_statement.subject_knowledge.change_action'),
      change_path: Rails.application.routes.url_helpers.candidate_interface_subject_knowledge_edit_path,
    }
  end
end
