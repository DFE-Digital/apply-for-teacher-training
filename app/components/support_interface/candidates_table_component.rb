module SupportInterface
  class CandidatesTableComponent < ActionView::Component::Base
    include ViewHelper

    def initialize(candidates:)
      @candidates = candidates
    end

    def table_rows
      candidates.map do |candidate|
        {
          candidate_id: candidate.id,
          process_state: process_state(candidate),
          candidate_link: govuk_link_to(candidate.email_address, support_interface_candidate_path(candidate)),
          updated_at: candidate.last_updated_application&.updated_at&.to_s(:govuk_date_and_time),
        }
      end
    end

  private

    attr_reader :candidates

    def process_state(candidate)
      return :sign_up_email_bounced if candidate.sign_up_email_bounced

      ProcessState.new(candidate.last_updated_application).state
    end
  end
end
