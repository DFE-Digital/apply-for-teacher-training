module SupportInterface
  class CandidatesController < SupportInterfaceController
    def index
      @candidates = Candidate
        .includes(:application_forms)
        .order('candidates.updated_at desc')
    end
  end
end
