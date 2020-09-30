module CandidateInterface
  module DecoupledReferences
    class EmailController < BaseController
      before_action :set_reference

      def new; end
    end
  end
end
