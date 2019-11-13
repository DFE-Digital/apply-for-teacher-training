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
      @application_choice = ApplicationChoicePresenter.new(application_choice)
    end

    def respond
    end

    def new_reject
    end

    def new_confirm_reject
    end

    def create_reject
      redirect_to action: :show
    end

  private

    # Stub out the current user and their organisation. Will be replaced
    # by a proper ProviderUser when implementing Signin.
    def current_user
      fake_user_class = Struct.new(:provider)
      fake_provider_class = Struct.new(:code)
      fake_user_class.new(fake_provider_class.new('ABC'))
    end

    def application_choice
      GetApplicationChoicesForProvider.call(provider: current_user.provider)
        .find(params[:application_choice_id])
    end
  end
end
