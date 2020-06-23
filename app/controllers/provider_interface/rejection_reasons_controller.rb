module ProviderInterface
  class RejectionReasonsController < ProviderInterfaceController
    def new
      @application_choice = ApplicationChoice.find(params[:application_choice_id])
      @reasons_form = RejectionReasonsForm.new
      @reasons_form.begin!
    end

    def create
      @application_choice = ApplicationChoice.find(params[:application_choice_id])
      @reasons_form = RejectionReasonsForm.new(form_params)
      if @reasons_form.valid?
        @reasons_form.next_step!
        if @reasons_form.done?
          render :check_your_feedback
        else
          render :new
        end
      else
        render :new
      end
    end

    def form_params
      params.require('provider_interface_rejection_reasons_form')
        .permit(:alternative_rejection_reason, questions_attributes: {})
    end
  end
end
