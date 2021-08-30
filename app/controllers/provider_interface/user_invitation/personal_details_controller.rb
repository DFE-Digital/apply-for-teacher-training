module ProviderInterface
  module UserInvitation
    class PersonalDetailsController < BaseController
      def new
        @wizard = InviteUserWizard.new(invite_user_store)
      end

      def create
        @wizard = InviteUserWizard.new(invite_user_store, personal_details_params.merge(provider: @provider))
        if @wizard.valid?
          @wizard.save_state!
        else
          track_validation_error(@wizard)
          render :new
        end
      end

    private

      def personal_details_params
        params.require(:provider_interface_invite_user_wizard).permit(:first_name, :last_name, :email_address)
      end
    end
  end
end
