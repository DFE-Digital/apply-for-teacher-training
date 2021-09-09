module ProviderInterface
  module ConditionStatuses
    class ChecksController < ConditionStatusesController
      def edit
        @form_object = ConfirmConditionsWizard.new(condition_statuses_store, { offer: @application_choice.offer })
        @form_object.save_state!
      end

      def update
        @form_object = ConfirmConditionsWizard.new(condition_statuses_store, attributes_for_wizard)
        @form_object.save_state!

        if @form_object.valid?
          redirect_to edit_provider_interface_condition_statuses_check_path(@application_choice)
        else
          track_validation_error(@form_object)
          render 'provider_interface/condition_statuses/edit'
        end
      end
    end
  end
end
