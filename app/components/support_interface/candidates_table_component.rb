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
          process_state: ProcessState.new(candidate.last_updated_application).state,
          candidate_link: govuk_link_to(candidate.email_address, support_interface_candidate_path(candidate)),
          updated_at: candidate.updated_at.strftime('%e %b %Y at %l:%M%P'),
        }
      end
    end

  private

    attr_reader :candidates
  end
end
