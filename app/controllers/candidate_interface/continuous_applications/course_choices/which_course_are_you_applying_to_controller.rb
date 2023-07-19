module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class WhichCourseAreYouApplyingToController < ::CandidateInterface::ContinuousApplicationsController
        before_action :available_courses, only: %i[new create]

        def new
          @wizard = CourseSelectionWizard.new(current_step:)
        end

        def create
          @wizard = CourseSelectionWizard.new(
            current_step:,
            step_params: params,
          )

          if @wizard.valid_step?
            redirect_to @wizard.next_step_path
          else
            # display some validation flash errors?
            render :new
          end
        end

      private

        def current_step
          :which_course_are_you_applying_to
        end

        def available_courses; end
      end
    end
  end
end
