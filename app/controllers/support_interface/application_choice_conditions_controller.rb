module SupportInterface
  class ApplicationChoiceConditionsController < SupportInterfaceController
    def edit
      @form = SupportInterface::ConditionsForm.build_from_application_choice(application_choice)
    end

    def update
      @form = SupportInterface::ConditionsForm.build_from_params(
        application_choice,
        condition_params,
      )

      if @form.save
        flash[:success] = 'Offer conditions updated'
        redirect_to support_interface_application_form_path(@form.application_choice.application_form_id)
      else
        render :edit
      end
    end

  private

    def application_choice
      @application_choice = ApplicationChoice.find(params[:application_choice_id])
    end

    def condition_params
      params
        .require(:support_interface_conditions_form)
        .permit(:application_choice_id, :audit_comment, further_conditions: {}, standard_conditions: [])
        .to_h
        .with_indifferent_access
    end
  end
end
