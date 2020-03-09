module CandidateInterface
  class SafeguardingIssuesDeclarationForm
    include ActiveModel::Model

    attr_accessor :share_safeguarding_issues, :safeguarding_issues

    validates :share_safeguarding_issues, presence: true
    validates :safeguarding_issues, word_count: { maximum: 400 }
  end
end
