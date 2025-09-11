module SupportInterface
  class CandidatesTableComponent < ApplicationComponent
    include ViewHelper

    def initialize(candidates:)
      @candidates = candidates
    end

    def table_rows
      candidates.map do |candidate|
        {
          candidate_id: candidate.id,
          candidate_flow_application_state: state(candidate),
          candidate_link: govuk_link_to(candidate.email_address, support_interface_candidate_path(candidate)),
          updated_at: candidate.updated_at&.to_fs(:govuk_date_and_time),
          apply_again: candidate.last_updated_application&.apply_2?,
        }
      end
    end

  private

    attr_reader :candidates

    def state(candidate)
      return :sign_up_email_bounced if candidate.sign_up_email_bounced

      ApplicationFormStateInferrer.new(candidate.last_updated_application).state
    end
  end
end
