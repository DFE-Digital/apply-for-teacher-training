module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class DoYouKnowWhichCourseController < ::CandidateInterface::ContinuousApplicationsController
        def new
          @wizard = CandidateInterface::CourseSelectionWizard.new(current_step:)
        end

        def create
          @wizard = CandidateInterface::CourseSelectionWizard.new(
            current_step:,
            step_params: params,
          )

          if @wizard.valid_step?
            redirect_to @wizard.next_step_path
          else
            render :new
          end
        end

      private

        def current_step
          :do_you_know_the_course
        end
      end
    end
  end
end
