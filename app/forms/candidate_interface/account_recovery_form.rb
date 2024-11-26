module CandidateInterface
  class AccountRecoveryForm
    include ActiveModel::Model

    attr_accessor :code
    attr_reader :valid_account_recovery_request, :current_candidate, :old_candidate

    validates :code, presence: true
    validate :account_recovery, unless: -> { valid_account_recovery_request && old_candidate }
    validate :account_recovery, if: -> { valid_account_recovery_request && old_candidate }

    def initialize(current_candidate:, code: nil)
      self.code = code
      @current_candidate = current_candidate
    end

    def call
      @valid_account_recovery_request = AccountRecoveryRequest.where(code:)
        .where('created_at >= ?', 1.hour.ago).first
      @old_candidate = Candidate.find_by(email_address: valid_account_recovery_request&.previous_account_email)

      return false unless valid?
      # raise error if previous account has one login auth?

      ActiveRecord::Base.transaction do
        old_candidate.update!(recovered: true)
        current_candidate.one_login_auth.update!(candidate: old_candidate)
        current_candidate.reload
        current_candidate.destroy!

        # Use audited on OneLoginAuth and AccountRecoveryRequest to monitor everything?
      end
    end

  private

    def account_recovery
      errors.add(:code, :invalid)
    end

    def previous_account_has_no_one_login
      if old_candidate.one_login_auth.present?
        errors.add(:code, :invalid)
        ## Add LOGIT/Sentry error
      end
    end
  end
end
