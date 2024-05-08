module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class TdaReviewInterruptionController < BaseController
        before_action :redirect_to_your_applications_if_submitted

        def show
        end
      end
    end
  end
end
