module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class BaseController < ::CandidateInterface::ContinuousApplicationsController
        def new
          @wizard = CourseSelectionWizard.new(current_step:, step_params:)
        end

        def create
          @wizard = CourseSelectionWizard.new(
            current_step:,
            step_params:,
          )

          if @wizard.valid_step?
            handle_valid_step
            redirect_to @wizard.next_step_path
          else
            render :new
          end
        end

        def current_step
          raise NotImplementedError
        end

        def step_params
          raise NotImplementedError
        end

        # method signature
        def handle_valid_step; end
      end
    end
  end
end
