module ProviderInterface
  class ChangeDecisionController < ProviderInterfaceController
    def new
      @application_choice = ApplicationChoice.find(params[:application_choice_id])
    end

    def dispatch_decision
      case params[:desired_change]
      when 'reject'
        redirect_to controller: :decisions, action: :new_reject
      else
        @application_choice = ApplicationChoice.find(params[:application_choice_id])
        render :new
      end
    end
  end
end
