module SupportInterface
  class ManageVendorsController < SupportInterfaceController
    def index
      @providers = Provider.all
    end

    def create
      GenerateVendorProviders.call
      redirect_back(fallback_location: root_path)
    end
  end
end
