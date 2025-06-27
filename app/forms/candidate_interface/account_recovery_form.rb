module CandidateInterface
  class AccountRecoveryForm
    include ActiveModel::Model

    attr_accessor :code
    attr_reader :valid_account_recovery_request, :current_candidate, :old_candidate, :id_token_hint

    validates :code, presence: true
    validates :code, numericality: { only_integer: true }, length: { is: 6 }

    validate :account_recovery, unless: -> { valid_account_recovery_request && old_candidate }
    validate :previous_account_has_no_one_login, if: -> { valid_account_recovery_request && old_candidate }

    def initialize(current_candidate:, code: nil)
      self.code = code
      @current_candidate = current_candidate
      @id_token_hint = current_candidate.sessions.last.id_token_hint
    end

    def call
      valid_request_code = current_candidate.account_recovery_request.codes.not_expired.find do |requested_code|
        requested_code.authenticate_code(code)
      end

      @valid_account_recovery_request = valid_request_code&.account_recovery_request
      @old_candidate = Candidate.find_by(email_address: valid_account_recovery_request&.previous_account_email_address)

      return false unless valid?

      ActiveRecord::Base.transaction do
        old_candidate.account_recovery_status_recovered!
        current_candidate.one_login_auth.update!(candidate: old_candidate)
        current_candidate.reload
        current_candidate.destroy!
      end
    end

    def requested_new_code?
      current_candidate.account_recovery_request.codes.not_expired.many?
    end

  private

    def account_recovery
      errors.add(:code, :invalid)
    end

    def previous_account_has_no_one_login
      if old_candidate.one_login_auth.present?
        errors.add(:code, :one_login_already_present)
      end
    end
  end
end
