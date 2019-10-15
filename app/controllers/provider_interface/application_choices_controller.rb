module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    def index
      application_choices = ApplicationChoice
        .includes(:application_form)
        .order(updated_at: :desc)
        .for_provider(current_user.provider.code)

      @application_choices = application_choices.map do |application_choice|
        ApplicationChoicePresenter.new(application_choice)
      end
    end

    def show
      application_choice = ApplicationChoice
        .includes(:application_form)
        .for_provider(current_user.provider.code)
        .find(params[:application_choice_id])

      @application_choice = ApplicationChoicePresenter.new(application_choice)
    end

  private

    # Stub out the current user and their organisation. Will be replaced
    # by a proper ProviderUser when implementing Signin.
    def current_user
      fake_user_class = Struct.new(:provider_ucas_code)
      fake_user_class.new('ABC')
    end
  end
end
