module CandidateInterface
  module CourseChoices
    class BlockedSubmissionsController < CandidateInterfaceController
      include CandidateInterface::ContinuousApplications
      def show; end
    end
  end
end
