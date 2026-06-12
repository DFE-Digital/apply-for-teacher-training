module ProviderInterface
  module CandidatePool
    class NotInPoolController < ApplicationController
      def show
        @candidate = Candidate.find(params.expect(:candidate_id))
      end
    end
  end
end
