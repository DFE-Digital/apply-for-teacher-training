module ProviderInterface
  module UserInvitation
    class PersonalDetailsController < BaseController
      skip_before_action :redirect_to_index_if_store_cleared, only: :new

      def new
        @wizard = InviteUserWizard.new(
          invite_user_store,
          current_step: :personal_details,
          checking_answers: params[:checking_answers] == 'true',
        )
        @wizard.save_state!
      end

      def create
        @wizard = InviteUserWizard.new(invite_user_store, personal_details_params.merge(provider: @provider))
        if @wizard.valid?
          @wizard.save_state!
          redirect_to next_page_path
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
