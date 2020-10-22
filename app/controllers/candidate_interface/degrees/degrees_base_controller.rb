module CandidateInterface
  module Degrees
    class DegreesBaseController < CandidateInterfaceController
      def current_degree
        current_application.application_qualifications.degrees.find(params[:id])
      end
    end
  end
end
