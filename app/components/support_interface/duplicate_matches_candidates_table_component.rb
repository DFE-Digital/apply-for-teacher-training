module SupportInterface
  class DuplicateMatchesCandidatesTableComponent < ApplicationComponent
    include ViewHelper

    DuplicatedMatch = Struct.new(
      :email_address, :candidate_id, :created_at, :name, :date_of_birth, :address, :application_status, :account_status,
      :one_login_email_address, :application_progress, :safeguarding_concerns, :reference_safeguarding_concerns, :current_application
    )

    attr_reader :match

    def initialize(match)
      @match = match
    end

    def accounts
      @accounts ||= @match.candidates.order(created_at: :desc).map do |candidate|
        current_application = candidate.current_application

        DuplicatedMatch.new(
          current_application: current_application,
          email_address: candidate.email_address,
          one_login_email_address: candidate.one_login_auth&.email_address,
          candidate_id: candidate.id,
          created_at: candidate.created_at.to_fs(:govuk_date_and_time),
          name: current_application.full_name,
          date_of_birth: match.date_of_birth.to_fs(:govuk_date_short_month),
          address: current_application.full_address,
          application_status: current_application.application_choices.not_unsubmitted.count,
          application_progress: current_application.application_choices.group(:status).count.sort_by { |_k, v| v },
          safeguarding_concerns: current_application.has_safeguarding_issues_to_declare? ? 'Safeguarding issue declared' : nil,
          reference_safeguarding_concerns: if current_application.application_references.any?(&:has_safeguarding_concerns_to_declare?)
                                             'Reference with safeguarding issue'
                                           end,
          account_status: account_status_for(candidate),
        )
      end
    end

  private

    def account_status_for(candidate)
      if candidate.account_locked?
        'Locked'
      elsif candidate.submission_blocked?
        'Application submission blocked'
      else
        'Active'
      end
    end
  end
end
