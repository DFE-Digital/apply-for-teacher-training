module CandidateInterface
  class SafeguardingIssuesDeclarationForm
    include ActiveModel::Model

    attr_accessor :share_safeguarding_issues, :safeguarding_issues

    validates :share_safeguarding_issues, presence: true
    validates :safeguarding_issues, word_count: { maximum: 400 }

    def save(application_form)
      return false unless valid?

      if share_safeguarding_issues == 'Yes' && safeguarding_issues.present?
        application_form.update(safeguarding_issues: safeguarding_issues)
      else
        application_form.update(safeguarding_issues: share_safeguarding_issues)
      end
    end
  end
end
