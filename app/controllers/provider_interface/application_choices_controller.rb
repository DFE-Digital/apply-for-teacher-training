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

  private

    # Stub out the current user and their organisation. Will be replaced
    # by a proper ProviderUser when implementing Signin.
    def current_user
      fake_user_class = Struct.new(:provider)
      fake_provider = Provider.find_by(code: 'ABC')
      fake_user_class.new(fake_provider)
    end
  end
end
