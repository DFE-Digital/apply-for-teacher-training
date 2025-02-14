module ProviderInterface
  class RejectionsController < ProviderInterfaceController
    include ClearWizardCache

    before_action :set_application_choice
    before_action :check_application_is_rejectable

    def new
      clear_wizard_if_new_entry(RejectionsWizard.new(store, {}))
      @wizard = wizard_class.new(store, current_step: 'new')
      @wizard.save_state!
    end

    def create
      @wizard = wizard_class.new(store, rejection_reasons_params.merge(current_step: 'new'))

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to action: @wizard.next_step
      else
        track_validation_error(@wizard)
        render :new
      end
    end

    def check
      @wizard = wizard_class.new(store, current_step: 'check')
      @back_link_path = new_provider_interface_rejection_path(@application_choice)
      @interview_cancellation_presenter = InterviewCancellationExplanationPresenter.new(@application_choice)
    end

    def commit
      @wizard = wizard_class.new(store)

      if service.save
        @wizard.clear_state!
        OfferWizard.new(offer_store).clear_state!

        flash[:success] = 'Application rejected'
        redirect_to provider_interface_application_choice_feedback_path(@application_choice)
      else
        @back_link_path = new_provider_interface_rejection_path(@application_choice)
        @interview_cancellation_presenter = InterviewCancellationExplanationPresenter.new(@application_choice)
        @wizard.errors.merge!(service.errors)
        track_validation_error(@wizard)
        render :check
      end
    end

  private

    def service
      @service ||= RejectApplication.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        structured_rejection_reasons: @wizard.object,
      )
    end

    def store
      key = "rejections_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key:)
    end

    def offer_store
      key = "offer_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key:)
    end

    def rejection_reasons_params
      params.require(:provider_interface_rejections_wizard).permit(*wizard_class.single_attribute_names, collection_attributes)
    end

    def collection_attributes
      wizard_class.collection_attribute_names.index_with { |_| [] }
    end

    def wizard_class
      ::ProviderInterface::RejectionsWizard
    end

    def check_application_is_rejectable
      return if ApplicationStateChange.new(@application_choice).can_reject?
      return if @application_choice.rejected_by_default?

      render_404
    end

    def wizard_entrypoint_paths
      [new_provider_interface_application_choice_decision_path]
    end
  end
end
