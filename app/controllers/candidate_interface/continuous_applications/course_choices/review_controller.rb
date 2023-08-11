module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class ReviewController < BaseController
        def show
          @application_choice = current_application.application_choices.find(params[:application_choice_id])
          @submit_application_form = CandidateInterface::ContinuousApplications::SubmitApplicationForm.new(
            application_choice: @application_choice,
          )
        end
      end
    end
  end
end
