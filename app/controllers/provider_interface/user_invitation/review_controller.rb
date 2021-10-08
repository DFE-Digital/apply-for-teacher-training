module ProviderInterface
  module UserInvitation
    class ReviewController < BaseController
      def check
        @wizard = InviteUserWizard.new(
          invite_user_store,
          current_step: :check,
        )
      end

      def commit
        @wizard = InviteUserWizard.new(invite_user_store, provider: @provider)

        save_service = AddUserToProvider.new(
          actor: current_provider_user,
          provider: @provider,
          email_address: @wizard.email_address,
          first_name: @wizard.first_name,
          last_name: @wizard.last_name,
          permissions: @wizard.permissions,
        )
        service = SaveAndInviteProviderUser.new(
          form: @wizard,
          save_service: save_service,
          invite_service: InviteProviderUser.new(provider_user: @wizard.email_address),
          new_user: new_user?(@wizard.email_address),
        )
        if service.call
          @wizard.clear_state!

          flash[:success] = 'User added'
          redirect_to provider_interface_organisation_settings_organisation_users_path(@provider)
        else
          track_validation_error(@wizard)
          render :check
        end
      end

    private

      def new_user?(email)
        !ProviderUser.exists?(email_address: email)
      end
    end
  end
end
