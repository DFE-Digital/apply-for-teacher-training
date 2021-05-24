module CandidateInterface
  module References
    class StartController < BaseController
      def show
        @application_form = current_application
      end
    end
  end
end
