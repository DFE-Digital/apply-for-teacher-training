module SupportInterface
  module BulkUpload
    class ProviderUsersController < SupportInterfaceController
      def create
        @wizard = MultipleProviderUsersWizard.new(
          state_store: multiple_provider_user_store,
          provider_id: provider_id_param,
        )

        if save_to_db_and_invite!(@wizard)
          flash[:success] = success_message(@wizard)
          @wizard.clear_state!
          redirect_to support_interface_provider_user_list_path
        else
          flash[:error] = 'Something went wrong'
          redirect_to support_interface_bulk_upload_checks_path unless @wizard.save_to_db_and_invite!
        end
      end

    private

      def save_to_db_and_invite!(wizard)
        forms = wizard.all_single_provider_user_forms
        services = save_and_invite_provider_user_services(forms)

        services.each(&:call)
      end

      def save_and_invite_provider_user_services(forms)
        forms.map do |form|
          provider_user = form.build

          SaveAndInviteProviderUser.new(
            form: form,
            save_service: SaveProviderUser.new(
              provider_user: provider_user,
              provider_permissions: [form.provider_permissions],
            ),
            invite_service: InviteProviderUser.new(provider_user: provider_user),
          )
        end
      end

      def multiple_provider_user_store
        key = "multiple_provider_user_store_#{provider_id_param}"
        WizardStateStores::RedisStore.new(key: key)
      end

      def provider_id_param
        params[:provider_id].to_i
      end

      def success_message(wizard)
        if wizard.provider_user_count > 1
          "#{wizard.provider_user_count} users added"
        else
          "User #{wizard.provider_user_name} added"
        end
      end
    end
  end
end
