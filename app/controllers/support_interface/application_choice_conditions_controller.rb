module SupportInterface
  class ApplicationChoiceConditionsController < SupportInterfaceController
    def edit
      @form = SupportInterface::ConditionsForm.new(
        application_choice: application_choice,
      )
    end

    def update
    end

  private

    def application_choice
      @application_choice = ApplicationChoice.find(condition_params[:application_choice_id])
    end

    def condition_params
      params
        .permit(:application_choice_id)
        .to_h
    end
  end
end
