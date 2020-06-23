module ProviderInterface
  class RejectionReasonsController < ProviderInterfaceController
    def new
      @application_choice = ApplicationChoice.find(params[:application_choice_id])
      @reasons_form = RejectionReasonsForm.new
      @reasons_form.begin!
    end

    def confirm
      @application_choice = ApplicationChoice.find(params[:application_choice_id])
      @reasons_form = RejectionReasonsForm.new(form_params)
      if @reasons_form.valid?
        @reasons_form.next_step!
        if @reasons_form.done?
          render :confirm
        else
          render :new
        end
      else
        render :new
      end
    end

    def create
      @application_choice = ApplicationChoice.find(params[:application_choice_id])
      @reasons_form = RejectionReasonsForm.new(form_params)
      @reject_application = RejectApplication.new(
        application_choice: @application_choice,
        rejection_reasons: @reasons_form.all_answered_questions,
      )

      if @reject_application.save
        flash[:success] = 'Application successfully rejected'
        redirect_to provider_interface_application_choice_path(
          application_choice_id: @application_choice.id,
        )
      else
        render action: :confirm
      end
    end

    def form_params
      params.require('provider_interface_rejection_reasons_form')
        .permit(:alternative_rejection_reason, questions_attributes: {})
    end
  end
end
