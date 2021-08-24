module ProviderInterface
  module UserInvitation
    class PermissionsController < BaseController
      def new
        @wizard = InviteUserWizard.new(invite_user_store)
      end

      def create
        @wizard = InviteUserWizard.new(invite_user_store, permissions_params)
        @wizard.save_state!
      end

    private

      def permissions_params
        params.require(:provider_interface_invite_user_wizard).permit(permissions: [])
      end
    end
  end
end
