module CandidateInterface
  module NewReferences
    class RequestReference::StartController < BaseController
      include RequestReferenceOfferDashboard

      def new; end
    end
  end
end
