module ProviderInterface
  module CandidatePool
    class NotInPoolController < ApplicationController
      def show
        @candidate = Candidate.find(params[:candidate_id])
      end
    end
  end
end
