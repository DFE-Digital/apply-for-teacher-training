module CandidateInterface
  class SafeguardingIssuesDeclarationForm
    include ActiveModel::Model

    attr_accessor :share_safeguarding_issues, :safeguarding_issues

    validates :share_safeguarding_issues, presence: true
    validates :safeguarding_issues, word_count: { maximum: 400 }

    def self.build_from_application(application_form)
      if (application_form.safeguarding_issues == 'Yes') || (application_form.safeguarding_issues == 'No')
        new(share_safeguarding_issues: application_form.safeguarding_issues)
      elsif application_form.safeguarding_issues.present?
        new(
          share_safeguarding_issues: 'Yes',
          safeguarding_issues: application_form.safeguarding_issues,
        )
      else
        new(share_safeguarding_issues: nil, safeguarding_issues: nil)
      end
    end

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
