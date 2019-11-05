module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    def index
      application_choices = ApplicationChoice
        .for_provider(current_user.provider.code)
        .visible_to_provider
        .order(updated_at: :desc)

      @application_choices = application_choices.map do |application_choice|
        ApplicationChoicePresenter.new(application_choice)
      end
    end

    def show
      application_choice = ApplicationChoice
        .for_provider(current_user.provider.code)
        .visible_to_provider
        .find(params[:application_choice_id])

      @application_choice = ApplicationChoicePresenter.new(application_choice)
    end

  private

    # Stub out the current user and their organisation. Will be replaced
    # by a proper ProviderUser when implementing Signin.
    def current_user
      fake_user_class = Struct.new(:provider)
      fake_provider_class = Struct.new(:code)
      fake_user_class.new(fake_provider_class.new('ABC'))
    end
  end
end
