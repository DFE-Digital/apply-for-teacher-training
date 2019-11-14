module ProviderInterface
  class DecisionsController < ProviderInterfaceController
    before_action :set_application_choice_and_presenter

    def respond; end

    def submit_response
      Rails.logger.warn params.inspect
      decision = params[:application_choice][:decision] if params[:application_choice]
      if decision == 'offer'
        redirect_to action: :new_offer
      elsif decision == 'reject'
        redirect_to action: :new_reject
      else
        raise 'Unexpected application_choice decision'
      end
    end

    def new_offer
      raise 'Not yet implemented'
    end

    def new_reject; end

    def confirm_reject
      @rejection_comments = params[:application_choice][:comments] if params[:application_choice]
      if @rejection_comments.blank?
        flash[:errors] = [
          { link_to: '#comments', message: 'Please provide feedback for the candidate' },
        ]
        redirect_to action: :new_reject
      end
    end

    def create_reject
      flash[:success] = 'Application status changed to \'Rejected\''
      redirect_to provider_interface_application_choice_path(
        application_choice_id: @application_choice.id,
      )
    end

  private

    def set_application_choice_and_presenter
      @application_choice = GetApplicationChoicesForProvider.call(provider: current_user.provider)
        .find(params[:application_choice_id])

      @presenter = ApplicationChoicePresenter.new(@application_choice)
    end
  end
end
