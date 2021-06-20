module SupportInterface
  module BulkUpload
    class ProviderUsersDetailsController < SupportInterfaceController
      def new
        @provider = Provider.find(provider_id_param)
        @wizard = MultipleProviderUsersWizard.build(
          state_store: multiple_provider_user_store,
          provider_id: provider_id_param,
        )
      end

      def create
        @provider = Provider.find(provider_id_param)
        @wizard = MultipleProviderUsersWizard.new(
          state_store: multiple_provider_user_store,
          provider_users: form_params[:provider_users],
          provider_id: form_params[:provider_id],
        )

        if @wizard.valid?
          @wizard.save_users_to_state_store!

          redirect_to edit_support_interface_bulk_upload_permissions_path(position: 1)
        else
          track_validation_error(@wizard)
          render :new
        end
      end

    private

      def form_params
        params.require(:support_interface_multiple_provider_users_wizard).permit(:provider_users)
      end

      def provider_id_param
        params[:provider_id].to_i
      end

      def position_param
        params[:position].to_i
      end

      def multiple_provider_user_store
        key = "multiple_provider_user_store_#{provider_id_param}"
        WizardStateStores::RedisStore.new(key: key)
      end
    end
  end
end
