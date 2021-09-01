module ProviderInterface
  module UserInvitation
    class BaseController < ProviderInterfaceController
      before_action :set_provider
      before_action :assert_can_manage_users!
      before_action :redirect_unless_feature_flag_on

    protected

      def invite_user_store
        key = "invite_user_wizard_store_#{current_provider_user.id}_#{@provider.id}"
        WizardStateStores::RedisStore.new(key: key)
      end

    private

      def set_provider
        @provider = current_provider_user.providers.find(params[:organisation_id])
      end

      def assert_can_manage_users!
        render_403 unless current_provider_user.authorisation.can_manage_users_for?(provider: @provider)
      end

      def redirect_unless_feature_flag_on
        return if FeatureFlag.active?(:account_and_org_settings_changes)

        redirect_to provider_interface_organisation_settings_path
      end

      def next_page_path
        case @wizard.next_step
        when :permissions
          new_provider_interface_organisation_settings_organisation_user_invitation_permissions_path(@provider)
        when :check
          provider_interface_organisation_settings_organisation_user_invitation_check_path(@provider)
        end
      end

      def previous_page_path
        case @wizard.previous_step
        when :personal_details
          new_provider_interface_organisation_settings_organisation_user_invitation_personal_details_path(@provider)
        when :permissions
          new_provider_interface_organisation_settings_organisation_user_invitation_permissions_path(@provider)
        when :check
          provider_interface_organisation_settings_organisation_user_invitation_check_path(@provider)
        end
      end

      helper_method :previous_page_path
    end
  end
end
