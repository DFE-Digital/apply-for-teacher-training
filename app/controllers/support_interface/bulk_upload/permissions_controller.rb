module SupportInterface
  module BulkUpload
    class PermissionsController < SupportInterfaceController
      def edit
        multiple_provider_users_wizard = MultipleProviderUsersWizard.new(
          state_store: multiple_provider_user_store,
          provider_id: provider_id_param,
          index: index,
        )

        @provider = Provider.find(provider_id_param)
        @form = multiple_provider_users_wizard.single_provider_user_form(index)
        @position_and_count = multiple_provider_users_wizard.position_and_count
        @backlink_path = backlink_path
      end

      def update
        multiple_provider_users_wizard = MultipleProviderUsersWizard.new(
          state_store: multiple_provider_user_store,
          provider_id: provider_id_param,
          index: provider_user_params[:index],
        )

        @provider = Provider.find(provider_id_param)
        @position_and_count = multiple_provider_users_wizard.position_and_count
        @form = CreateSingleProviderUserForm.new(
          provider_user_params.merge(provider_permissions: provider_permissions_params),
        )

        if @form.valid?
          multiple_provider_users_wizard.save_user_to_state_store!(@form)

          if multiple_provider_users_wizard.no_more_users_to_process?
            redirect_to support_interface_bulk_upload_checks_path
          else
            redirect_to edit_support_interface_bulk_upload_permissions_path(position: multiple_provider_users_wizard.next_position)
          end
        else
          render :edit
        end
      end

    private

      def multiple_provider_user_store
        key = "multiple_provider_user_store_#{provider_id_param}"
        WizardStateStores::RedisStore.new(key: key)
      end

      def provider_id_param
        params[:provider_id].to_i
      end

      def position_param
        params[:position]&.to_i
      end

      def index
        position_param - 1
      end

      def provider_user_params
        params.require(:support_interface_create_single_provider_user_form)
              .permit(:email_address, :first_name, :last_name, :provider_id, :index)
      end

      def provider_permissions_params
        params.require(:support_interface_create_single_provider_user_form)
              .permit(provider_permissions_form: {})
              .fetch(:provider_permissions_form, {})
              .to_h
      end

      def backlink_path
        if index.zero?
          new_support_interface_bulk_upload_provider_users_details_path
        else
          edit_support_interface_bulk_upload_permissions_path(position: index)
        end
      end
    end
  end
end
