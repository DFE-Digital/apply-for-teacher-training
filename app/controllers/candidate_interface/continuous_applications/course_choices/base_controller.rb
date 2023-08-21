module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class BaseController < ::CandidateInterface::ContinuousApplicationsController
        before_action :redirect_to_your_applications_if_cycle_is_over
        before_action :redirect_to_your_applications_if_submitted, only: %i[edit update]

        def new
          @wizard = CourseSelectionWizard.new(
            current_step:,
            step_params:,
            current_application:,
          )
        end

        def edit
          @wizard = CourseSelectionWizard.new(
            current_step:,
            step_params: update_params,
            current_application:,
            application_choice:,
            edit: true,
          )
        end

        def create
          @wizard = CourseSelectionWizard.new(
            current_step:,
            step_params:,
            current_application:,
          )

          if @wizard.valid_step? && @wizard.save
            redirect_to @wizard.next_step_path
          else
            render :new
          end
        end

        def update
          @wizard = CourseSelectionWizard.new(
            current_step:,
            step_params: update_params,
            current_application:,
            application_choice:,
            edit: true,
          )

          if @wizard.valid_step? && @wizard.update
            redirect_to @wizard.next_step_path
          else
            render :edit
          end
        end

        def current_step
          raise NotImplementedError
        end

        def step_params
          return default_params if params[current_step].blank?

          params
        end

        def default_params
          ActionController::Parameters.new({ current_step => params })
        end

        def update_params
          return default_update_params if params[current_step].blank?

          params
        end

        def default_update_params
          ActionController::Parameters.new(
            {
              current_step => {
                provider_id: application_choice.current_provider.id,
                course_id: params[:course_id] || application_choice.current_course.id,
                study_mode: params[:study_mode] || application_choice.current_course_option.study_mode,
                course_option_id: application_choice.current_course_option.id,
              },
            },
          )
        end

        def application_choice
          @application_choice ||= current_application.application_choices.find(params[:application_choice_id])
        end

      private

        def redirect_to_your_applications_if_cycle_is_over
          redirect_to candidate_interface_continuous_applications_choices_path unless CycleTimetable.can_add_course_choice?(current_application)
        end
      end
    end
  end
end
