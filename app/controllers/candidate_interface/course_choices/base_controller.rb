module CandidateInterface
  module CourseChoices
    class BaseController < CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action CarryOverFilter
      before_action :redirect_to_your_applications_if_maximum_amount_of_choices_have_been_used, only: %i[new create]
      before_action :redirect_to_your_applications_if_maximum_amount_of_unsuccessful_applications_have_been_reached, only: %i[new create]
      before_action :redirect_to_your_applications_if_cycle_is_over
      before_action :redirect_to_your_applications_if_submitted, only: %i[edit update]
      before_action :assign_wizard
      before_action :assign_wizard_with_application_choice, only: %i[edit update]

      def new; end

      def edit
        @back_link = if params[:return_to] == 'review'
                       candidate_interface_course_choices_course_review_path
                     else
                       @wizard.previous_step_path
                     end
      end

      def create
        if @wizard.current_step_valid?
          @wizard.save_current_step
          redirect_to @wizard.next_step_path
        else
          render :new
        end
      end

      def update
        if @wizard.current_step_valid?
          @wizard.save_current_step
          redirect_to @wizard.next_step_path
        else
          render :edit
        end
      end

      def current_step
        raise NotImplementedError
      end

      def step_params
        if action_name.in?(%w[edit update])
          update_params
        else
          params
        end
      end

      def update_params
        ActionController::Parameters.new(
          {
            current_step => {
              application_choice_id: application_choice.id,
              provider_id: application_choice.current_provider.id,
              course_id: params.dig(current_step, :course_id) || application_choice.current_course.id,
              study_mode: params.dig(current_step, :study_mode) || application_choice.current_course_option.study_mode,
              course_option_id: params.dig(current_step, :course_option_id) || application_choice.current_course_option.id,
              visa_explanation: params.dig(current_step, :visa_explanation) || application_choice.visa_explanation,
            },
          },
        )
      end

      def application_choice
        return @application_choice if defined?(@application_choice)

        @application_choice = active_application_choices.find_by(id: params[:application_choice_id])
      end

    private

      def wizard_controller?
        false
      end

      def redirect_to_your_applications_if_cycle_is_over
        redirect_to candidate_interface_application_choices_path unless current_application.can_add_course_choice?
      end

      def redirect_to_your_applications_if_maximum_amount_of_choices_have_been_used
        redirect_to candidate_interface_application_choices_path unless current_application.can_add_more_choices?
      end

      def redirect_to_your_applications_if_maximum_amount_of_unsuccessful_applications_have_been_reached
        redirect_to candidate_interface_application_choices_path if current_application.unsuccessful_limit_reached?
      end

      def assign_wizard
        return unless wizard_controller?

        @wizard = CandidateInterface::CourseSelectionWizard.new(
          current_step:,
          current_step_params: step_params,
          state_store:,
        ).tap do |wizard|
          wizard.current_application = current_application
        end
      end

      def assign_wizard_with_application_choice
        return if @wizard.blank?

        @wizard = @wizard.tap do |wizard|
          wizard.application_choice = application_choice
        end
        state_store.write(application_choice_id: application_choice.id)
      end

      def state_store
        @state_store = CandidateInterface::StateStores::CourseSelectionWizardStore.new(
          repository: DfE::Wizard::Repository::Cache.new(
            cache: Rails.cache,
            key:,
            expires_in: 7.days,
          ),
        )
        @state_store.write(current_application_id: current_application.id)
        @state_store
      end

      def key
        @key ||= if application_choice.present?
                   "candidate_interface_course_selection_wizard_#{current_application.id}_#{application_choice.id}"
                 else
                   "candidate_interface_course_selection_wizard_#{current_application.id}_new"
                 end.to_sym
      end

      def clear_wizard
        @wizard&.clear_state
      end
    end
  end
end
