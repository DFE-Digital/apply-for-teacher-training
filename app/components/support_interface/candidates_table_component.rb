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
          candidate_link: candidate.email_address,
          updated_at: candidate.updated_at.strftime('%e %b %Y at %l:%M%P'),
        }
      end
    end

  private

    attr_reader :candidates
  end
end
