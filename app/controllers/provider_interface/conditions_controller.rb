module ProviderInterface
  class ConditionsController < ProviderInterfaceController
    before_action :set_application_choice

    def edit
      @conditions_form = ConfirmConditionsForm.new
    end

    def confirm_update
      @conditions_form = ConfirmConditionsForm.new(
        conditions_met: params.dig(:provider_interface_confirm_conditions_form, :conditions_met),
      )

      render action: :edit unless @conditions_form.valid?
    end

    def update
      @conditions_form = ConfirmConditionsForm.new(
        conditions_met: params.dig(:provider_interface_confirm_conditions_form, :conditions_met),
      )

      redirect_to action: :edit unless @conditions_form.valid?

      if @conditions_form.conditions_met?
        ConfirmOfferConditions.new(application_choice: @application_choice).save || raise('ConfirmOfferConditions failure')
        flash[:success] = 'Conditions successfully marked as met'
      else
        ConditionsNotMet.new(application_choice: @application_choice).save || raise('ConditionsNotMet failure')
        flash[:success] = 'Conditions successfully marked as not met'
      end

      redirect_to provider_interface_application_choice_path(@application_choice.id)
    end

  private

    def set_application_choice
      @application_choice = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .find(params[:application_choice_id])
    end
  end
end
