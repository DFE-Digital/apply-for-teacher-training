module SupportInterface
  class CandidateAccountStatusForm
    include ActiveModel::Model

    attr_accessor :candidate
    attr_writer :status

    ACCOUNT_SUBMISSION_BLOCKED = 'account_submission_blocked'.freeze
    ACCOUNT_ACCESS_LOCKED = 'account_access_locked'.freeze
    UNBLOCKED = 'unblocked'.freeze

    def status
      return @status if @status.present?

      if candidate.submission_blocked?
        ACCOUNT_SUBMISSION_BLOCKED
      elsif candidate.account_locked?
        ACCOUNT_ACCESS_LOCKED
      else
        UNBLOCKED
      end
    end

    def unblocked?
      status == UNBLOCKED
    end

    def update!
      if status == ACCOUNT_SUBMISSION_BLOCKED
        @candidate.update(
          submission_blocked: true,
          account_locked: false,
        )
      elsif status == ACCOUNT_ACCESS_LOCKED
        @candidate.update(
          submission_blocked: false,
          account_locked: true,
        )
      else
        @candidate.update(
          submission_blocked: false,
          account_locked: false,
        )
      end
    end
  end
end
