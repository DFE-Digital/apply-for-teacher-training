module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class BaseController < ::CandidateInterface::ContinuousApplicationsController
        def new
          @wizard = CourseSelectionWizard.new(
            current_step:,
            step_params:,
            request:,
            current_application:,
          )
        end

        def create
          @wizard = CourseSelectionWizard.new(
            current_step:,
            step_params:,
            request:,
            current_application:,
          )

          if @wizard.valid_step? && @wizard.save
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
      end
    end
  end
end
