module CandidateInterface
  class AccountRecoveryRequestForm
    include ActiveModel::Model

    attr_accessor :previous_account_email_address
    attr_reader :current_candidate, :previous_candidate

    validates :previous_account_email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validate :email_different_from_current_candidate, if: -> { previous_candidate.present? }

    def initialize(current_candidate:, previous_account_email_address: nil)
      self.previous_account_email_address = previous_account_email_address&.downcase&.strip
      @current_candidate = current_candidate
    end

    def self.build_from_candidate(candidate)
      new(
        current_candidate: candidate,
        previous_account_email_address: candidate.account_recovery_request&.previous_account_email_address,
      )
    end

    def save_and_email_candidate
      @previous_candidate = Candidate.find_by(email_address: previous_account_email_address)
      return false unless valid?

      ActiveRecord::Base.transaction do
        account_recovery_request = find_or_create_account_recovery_request

        account_recovery_request_code = account_recovery_request.codes.create(
          code: AccountRecoveryRequestCode.generate_code,
        )

        if Candidate.find_by(email_address: previous_account_email_address).present?
          AccountRecoveryMailer.send_code(
            email: previous_account_email_address,
            code: account_recovery_request_code.code,
          ).deliver_later
        else
          true # We still want the user to progress to the next page
        end
      end
    end

  private

    def find_or_create_account_recovery_request
      AccountRecoveryRequest.find_by(
        candidate: current_candidate,
        previous_account_email_address:,
      ) || current_candidate.create_account_recovery_request(previous_account_email_address:)
    end

    def email_different_from_current_candidate
      if current_candidate.email_address == previous_account_email_address
        errors.add(:previous_account_email_address, :email_same_as_current_candidate)
      end
    end
  end
end
