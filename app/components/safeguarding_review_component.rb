class SafeguardingReviewComponent < ActionView::Component::Base
  def initialize(application_form:, editable: true)
    @safeguarding = CandidateInterface::SafeguardingIssuesDeclarationForm.build_from_application(application_form)
    @editable = editable
  end

  def safeguarding_rows
    [sharing_safeguarding_issues_row, relevant_information_row].compact
  end

private

  def sharing_safeguarding_issues_row
    {
      key: 'Do you want to share any information which could have an impact on your application?',
      value: @safeguarding.share_safeguarding_issues,
      action: 'if you want to share any safeguarding issues',
      change_path: candidate_interface_edit_safeguarding_path,
    }
  end

  def relevant_information_row
    return if @safeguarding.share_safeguarding_issues == 'No'

    {
      key: 'Relevant information',
      value: @safeguarding.safeguarding_issues || 'Not entered',
      action: 'relevant information for safeguarding issues',
      change_path: candidate_interface_edit_safeguarding_path,
    }
  end
end
