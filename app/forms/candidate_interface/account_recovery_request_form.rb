module CandidateInterface
  class AccountRecoveryRequestForm
    include ActiveModel::Model

    attr_accessor :previous_account_email
    attr_reader :current_candidate, :previous_candidate

    validates :previous_account_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validate :email_different_from_current_candidate, if: -> { previous_candidate.present? }

    def initialize(current_candidate:, previous_account_email: nil)
      self.previous_account_email = previous_account_email&.downcase&.strip
      @current_candidate = current_candidate
    end

    def self.build_from_candidate(candidate)
      new(
        current_candidate: candidate,
        previous_account_email: candidate.account_recovery_request&.previous_account_email,
      )
    end

    def save
      @previous_candidate = Candidate.find_by(email_address: previous_account_email)

      return false unless valid?

      ActiveRecord::Base.transaction do
        account_recovery_request = current_candidate.create_account_recovery_request(
          previous_account_email:,
          code: AccountRecoveryRequest.generate_code,
        )

        AccountRecoveryMailer.send_code(
          email: previous_account_email,
          code: account_recovery_request.code,
        ).deliver_later
      end
    end

  private

    def email_different_from_current_candidate
      if current_candidate.one_login_auth.email == previous_account_email
        errors.add(:previous_account_email, "You can't recover the same account you are logged in to")
      end
    end
  end
end
