module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class ReviewAndSubmitController < BaseController
        def show
          @application_choice = current_application.application_choices.find(params[:application_choice_id])
          @application_form = current_application
        end
      end
    end
  end
end
