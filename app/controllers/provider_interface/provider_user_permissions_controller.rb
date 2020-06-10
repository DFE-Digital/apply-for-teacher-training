module ProviderInterface
  class ProviderUserPermissionsController < ProviderInterfaceController
    def missing_permission
      @provider = Provider.find params[:provider_id]
      @provider_user = Provider.find params[:provider_user_id]
      @permission = params[:permission].humanize
    end
  end
end
