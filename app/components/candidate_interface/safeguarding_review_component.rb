module CandidateInterface
  class SafeguardingReviewComponent < ViewComponent::Base
    def initialize(application_form:, editable: true, missing_error: false, submitting_application: false, return_to_application_review: false)
      @application_form = application_form
      @safeguarding = CandidateInterface::SafeguardingIssuesDeclarationForm.build_from_application(application_form)
      @editable = editable
      @missing_error = missing_error
      @submitting_application = submitting_application
      @return_to_application_review = return_to_application_review
    end

    def safeguarding_rows
      [sharing_safeguarding_issues_row, relevant_information_row].compact
    end

    def show_missing_banner?
      !@application_form.safeguarding_issues_completed && @editable if @submitting_application
    end

  private

    def sharing_safeguarding_issues_row
      {
        key: 'Do you want to share any safeguarding issues?',
        value: @safeguarding.share_safeguarding_issues,
        action: 'if you want to share any safeguarding issues',
        change_path: candidate_interface_edit_safeguarding_path(return_to_params),
        data_qa: 'safeguarding-issues',
      }
    end

    def relevant_information_row
      return if @safeguarding.share_safeguarding_issues == 'No'

      {
        key: 'Relevant information',
        value: @safeguarding.safeguarding_issues || 'Not entered',
        action: 'relevant information for safeguarding issues',
        change_path: candidate_interface_edit_safeguarding_path(return_to_params),
      }
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end
  end
end
