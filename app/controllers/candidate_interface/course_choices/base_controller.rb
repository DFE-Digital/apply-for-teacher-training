module CandidateInterface
  module CourseChoices
    class BaseController < CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action CarryOverFilter
      before_action :redirect_to_your_applications_if_maximum_amount_of_choices_have_been_used, only: %i[new create]
      before_action :redirect_to_your_applications_if_maximum_amount_of_unsuccessful_applications_have_been_reached, only: %i[new create]
      before_action :redirect_to_your_applications_if_cycle_is_over
      before_action :redirect_to_your_applications_if_submitted, only: %i[edit update]

      def new
        @wizard = CandidateInterface::CourseChoices::CourseSelectionWizard.new(
          current_step:,
          step_params:,
          current_application:,
        )
      end

      def edit
        @wizard = CandidateInterface::CourseChoices::CourseSelectionWizard.new(
          current_step:,
          step_params: update_params,
          current_application:,
          application_choice:,
          edit: true,
        )
      end

      def create
        @wizard = CandidateInterface::CourseChoices::CourseSelectionWizard.new(
          current_step:,
          step_params:,
          current_application:,
        )

        if @wizard.save
          redirect_to @wizard.next_step_path
        else
          render :new
        end
      end

      def update
        @wizard = CandidateInterface::CourseChoices::CourseSelectionWizard.new(
          current_step:,
          step_params: update_params,
          current_application:,
          application_choice:,
          edit: true,
        )

        if @wizard.update
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
        redirect_to candidate_interface_application_choices_path unless current_application.can_add_course_choice?
      end

      def redirect_to_your_applications_if_maximum_amount_of_choices_have_been_used
        redirect_to candidate_interface_application_choices_path unless current_application.can_add_more_choices?
      end

      def redirect_to_your_applications_if_maximum_amount_of_unsuccessful_applications_have_been_reached
        redirect_to candidate_interface_application_choices_path if current_application.application_limit_reached?
      end
    end
  end
end
