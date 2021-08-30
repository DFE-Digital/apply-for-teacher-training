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
    end
  end
end
