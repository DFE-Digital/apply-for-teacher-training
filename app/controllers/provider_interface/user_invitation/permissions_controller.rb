module ProviderInterface
  module UserInvitation
    class PermissionsController < BaseController
      def new
        @wizard = InviteUserWizard.new(
          invite_user_store,
          current_step: :permissions,
          checking_answers: params[:checking_answers] == 'true',
        )
        @wizard.save_state!
      end

      def create
        @wizard = InviteUserWizard.new(invite_user_store, permissions_params)
        @wizard.save_state!

        redirect_to next_page_path
      end

    private

      def permissions_params
        params.require(:provider_interface_invite_user_wizard).permit(permissions: [])
      end
    end
  end
end
