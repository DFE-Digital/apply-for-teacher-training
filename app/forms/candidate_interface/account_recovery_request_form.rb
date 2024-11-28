module CandidateInterface
  class AccountRecoveryRequestForm
    include ActiveModel::Model

    attr_accessor :previous_account_email
    attr_reader :current_candidate, :previous_candidate

    validates :previous_account_email, presence: true
    validate :previous_account_has_no_one_login, if: -> { previous_candidate.present? }

    def initialize(current_candidate:, previous_account_email: nil)
      self.previous_account_email = previous_account_email
      @current_candidate = current_candidate
    end

    def save
      @previous_candidate = Candidate.find_by(email_address: previous_account_email)

      return false unless valid?

      @account_recovery_request = current_candidate.create_account_recovery_request(
        previous_account_email:,
        code: AccountRecoveryRequest.generate_code,
      )

      # send email if we find a candidate with previous_account_email
    end

  private

    def previous_account_has_no_one_login
      ### previous_candidate.one_login_auth.present? this should not be here, it should be on the account_recovery form
      ## we won't send an email to this, Displaying an error here indicates that this email exists in apply
      ## Log this in logit?
      if previous_candidate.one_login_auth.present? || current_candidate.one_login_auth.email == previous_account_email
        errors.add(:previous_account_email, 'The email already has a one login account')
      end
    end
  end
end
