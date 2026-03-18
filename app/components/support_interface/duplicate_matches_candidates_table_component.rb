module SupportInterface
  class DuplicateMatchesCandidatesTableComponent < ApplicationComponent
    include ViewHelper

    DuplicatedMatch = Struct.new(
      :email_address, :candidate_id, :created_at, :name, :date_of_birth, :address, :application_status, :account_status,
      keyword_init: true
    )

    attr_reader :match

    def initialize(match)
      @match = match
    end

    def accounts
      @match.candidates.map do |candidate|
        current_application = candidate.current_application

        DuplicatedMatch.new(
          email_address: candidate.email_address,
          candidate_id: candidate.id,
          created_at: candidate.created_at.to_fs(:govuk_date_and_time),
          name: current_application.full_name,
          date_of_birth: match.date_of_birth.to_fs(:govuk_date_short_month),
          address: current_application.full_address,
          application_status: current_application.submitted_at&.to_fs(:govuk_date_and_time) || 'Not submitted',
          account_status: account_status_for(candidate),
        )
      end
    end

  private

    def account_status_for(candidate)
      if candidate.account_locked?
        'Account locked'
      elsif candidate.submission_blocked?
        'Application submission blocked'
      else
        'Not blocked'
      end
    end
  end
end
