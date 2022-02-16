module ProviderInterface
  class RejectionReasonsController < ProviderInterfaceController
    before_action :set_application_choice

    def edit
      @wizard = wizard_class.new(store, current_step: 'edit')
      @wizard.save_state!
    end

    def update
      @wizard = wizard_class.new(store, rejection_reasons_params.merge(current_step: 'edit'))

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to action: @wizard.next_step
      else
        track_validation_error(@wizard)
        render :edit
      end
    end

    def check
      @wizard = wizard_class.new(store, current_step: 'check')
    end

    # TODO: Refactor this into a smaller service call.
    def commit
      @wizard = wizard_class.new(store)

      service = RejectApplication.new(actor: current_provider_user, application_choice: @application_choice, structured_rejection_reasons: @wizard.to_model)
      success_message = 'Application rejected'

      if service.save
        @wizard.clear_state!
        #OfferWizard.new(offer_store).clear_state!

        flash[:success] = success_message
        redirect_to provider_interface_application_choice_feedback_path(@application_choice)
      else
        @interview_cancellation_presenter = InterviewCancellationExplanationPresenter.new(@application_choice)
        @wizard.errors.merge!(service.errors)
        track_validation_error(@wizard)
        render :check
      end
    end

    def store
      key = "rejection_reasons_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end

    def rejection_reasons_params
      params.require(:rejection_reasons).permit(*wizard_class.attribute_names, array_attribute_params)
    end

    def array_attribute_params
      wizard_class.array_attribute_names.index_with { |_| [] }
    end

    def wizard_class
      RejectionReasonsWizard
    end
  end
end
