module CandidateInterface
  class AccountRecoveryForm
    include ActiveModel::Model

    attr_accessor :code
    attr_reader :valid_account_recovery_request, :current_candidate, :old_candidate

    validates :code, presence: true
    validate :account_recovery

    def initialize(current_candidate:, code: nil)
      self.code = code
      @current_candidate = current_candidate
      @valid_account_recovery_request = AccountRecoveryRequest.where(code:, successful: false)
        .where('created_at >= ?', 1.hour.ago).first
    end

    def call
      return false unless valid?

      @old_candidate = Candidate.find_by(email_address: @valid_account_recovery_request.previous_account_email)
      # current_candidate
      # The old candidate becomes the current_candidate.
      # dup the auth record from the current candidate to the old one, can we do this safely maybe in a transaction?
      # remove any data related to the current candidate, any personal information
      ActiveRecord::Base.transaction do
        current_candidate.one_login_auth.update!(candidate: old_candidate)
      end
    end

  private

    def account_recovery
      return if valid_account_recovery_request

      errors.add(:code, :invalid)
    end
  end
end
