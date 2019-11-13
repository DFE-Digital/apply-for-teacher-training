module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    before_action :set_application_choice

    def index
      application_choices = GetApplicationChoicesForProvider.call(provider: current_user.provider)
        .order(updated_at: :desc)

      @application_choices = application_choices.map do |application_choice|
        ApplicationChoicePresenter.new(application_choice)
      end
    end

    def show; end

  private

    def set_application_choice
      @application_choice = GetApplicationChoicesForProvider.call(provider: current_user.provider)
        .find(params[:application_choice_id])
    end
  end
end
