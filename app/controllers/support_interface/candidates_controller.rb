module SupportInterface
  class CandidatesController < SupportInterfaceController
    def index
      @candidates = Candidate
        .includes(:application_forms)
        .order('candidates.updated_at desc')
    end

    def show
      @candidate = Candidate.find(params[:candidate_id])
    end
  end
end
