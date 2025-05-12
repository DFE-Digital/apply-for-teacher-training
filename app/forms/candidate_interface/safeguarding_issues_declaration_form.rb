module CandidateInterface
  class SafeguardingIssuesDeclarationForm
    include ActiveModel::Model

    attr_accessor :share_safeguarding_issues, :safeguarding_issues

    validates :share_safeguarding_issues, presence: true
    validates :safeguarding_issues, presence: true, if: :share_safeguarding_issues?
    validates :safeguarding_issues, word_count: { maximum: 400 }

    def self.build_from_application(application_form)
      if application_form.has_safeguarding_issues_to_declare?
        new(share_safeguarding_issues: 'Yes', safeguarding_issues: application_form.safeguarding_issues)
      elsif application_form.no_safeguarding_issues_to_declare?
        new(share_safeguarding_issues: 'No')
      else
        new(share_safeguarding_issues: nil)
      end
    end

    def save(application_form)
      return false unless valid?

      if share_safeguarding_issues?
        application_form.update(
          safeguarding_issues:,
          safeguarding_issues_status: :has_safeguarding_issues_to_declare,
        )
      else
        application_form.update(
          safeguarding_issues: nil,
          safeguarding_issues_status: :no_safeguarding_issues_to_declare,
        )
      end
    end

    def share_safeguarding_issues?
      share_safeguarding_issues == 'Yes'
    end

    def all_errors
      validate(%i[share_safeguarding_issues])
      errors
    end

    def valid_for_submission?
      all_errors.blank?
    end
  end
end
