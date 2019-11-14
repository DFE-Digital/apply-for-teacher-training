module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController

    def index
      application_choices = GetApplicationChoicesForProvider.call(provider: current_user.provider)
        .order(updated_at: :desc)

      @application_choices = application_choices.map do |application_choice|
        ApplicationChoicePresenter.new(application_choice)
      end
    end

    def show
      application_choice = GetApplicationChoicesForProvider.call(provider: current_user.provider)
        .find(params[:application_choice_id])

      @application_choice = ApplicationChoicePresenter.new(application_choice)
    end
  end
end
