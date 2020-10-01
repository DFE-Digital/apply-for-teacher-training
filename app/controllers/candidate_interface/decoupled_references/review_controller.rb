module CandidateInterface
  module DecoupledReferences
    class ReviewController < CandidateInterfaceController
      def show
        @application_form = current_application
      end
    end
  end
end
