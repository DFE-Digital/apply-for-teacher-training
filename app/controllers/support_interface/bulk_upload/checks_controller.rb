module SupportInterface
  module BulkUpload
    class ChecksController < SupportInterfaceController
      def show
        @provider = Provider.find(provider_id_param)
        @wizard = MultipleProviderUsersWizard.new(
          state_store: multiple_provider_user_store,
          provider_id: provider_id_param,
        )
        @backlink_path = edit_support_interface_bulk_upload_permissions_path(position: @wizard.provider_user_count)
      end

    private

      def provider_id_param
        params[:provider_id].to_i
      end

      def multiple_provider_user_store
        key = "multiple_provider_user_store_#{provider_id_param}"
        WizardStateStores::RedisStore.new(key: key)
      end
    end
  end
end
