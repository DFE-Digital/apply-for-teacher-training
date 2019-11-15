module ProviderInterface
  class DecisionsController < ProviderInterfaceController
    before_action :set_application_choice_and_presenter

    def respond; end

    def submit_response
      decision = params[:application_choice][:decision] if params[:application_choice]
      if decision == 'offer'
        redirect_to action: :new_offer
      elsif decision == 'reject'
        redirect_to action: :new_reject
      end
    end

    def new_offer
      raise 'Not yet implemented'
    end

    def new_reject
      @reject_application = RejectApplication.new(application_choice: @application_choice)
    end

    def confirm_reject
      @reject_application = RejectApplication.new(
        application_choice: @application_choice,
        rejection_reason: params.dig(:reject_application, :rejection_reason),
      )
      render action: :new_reject if !@reject_application.valid?
    end

    def create_reject
      @reject_application = RejectApplication.new(
        application_choice: @application_choice,
        rejection_reason: params.dig(:reject_application, :rejection_reason),
      )
      if @reject_application.save
        flash[:success] = 'Application status changed to ‘Rejected’'
        redirect_to provider_interface_application_choice_path(
          application_choice_id: @application_choice.id,
        )
      else
        render action: :new_reject
      end
    end

  private

    def set_application_choice_and_presenter
      @application_choice = GetApplicationChoicesForProvider.call(provider: current_user.provider)
        .find(params[:application_choice_id])

      @presenter = ApplicationChoicePresenter.new(@application_choice)
    end
  end
end
