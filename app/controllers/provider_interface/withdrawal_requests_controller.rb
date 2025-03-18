module ProviderInterface
  class WithdrawalRequestsController < ProviderInterfaceController
    before_action :set_application_choice
    def new
      @withdrawal_request_form = WithdrawalRequestForm.new(application_choice: @application_choice)
    end

    def create
      @withdrawal_request_form = WithdrawalRequestForm.new(form_params, application_choice: @application_choice)

      if @withdrawal_request_form.valid?
        withdrawal_request = @withdrawal_request_form.persist!
        # TODO: Send some emails next PR
        redirect_to show_provider_interface_withdrawal_request_path(withdrawal_request)
      else
        render :new
      end
    end

    def show
      @withdrawal_request = @application_choice.withdrawal_requests.find(params[:id])
    end

  private

    def form_params
      params.expect(provider_interface_withdrawal_request_form: %i[reason comment])
    end
  end
end
