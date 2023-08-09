module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class ReviewController < BaseController
        def show
          @application_choice = current_application.application_choices.find(params[:application_choice_id])
          @submit_application_form = CandidateInterface::ContinuousApplications::SubmitApplicationForm.new(
            application_choice: @application_choice,
          )
          @application_can_submit = @submit_application_form.valid?(:submission)
        end
      end
    end
  end
end
