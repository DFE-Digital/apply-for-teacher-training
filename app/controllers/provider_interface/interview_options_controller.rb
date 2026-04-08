module ProviderInterface
  class InterviewOptionsController < ProviderInterfaceController
    before_action :set_provider
    before_action :authorize_user, only: %i[edit update]

    def show; end

    def edit; end

    def update
      if @provider.update(interview_option_params)
        flash[:success] = t('.success')
        redirect_to provider_interface_organisation_settings_organisation_interview_options_path
      else
        track_validation_error(@provider)
        render :edit
      end
    end

  private

    def authorize_user
      authorize @provider, :manage_organisation_permissions?
    end

    def interview_option_params
      params.fetch(:provider, {}).permit(:handle_interviews)
    end

    def set_provider
      @provider = current_provider_user.providers.find(params[:organisation_id])
    end
  end
end
