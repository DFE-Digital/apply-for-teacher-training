module SupportInterface
  class ManageVendorsController < SupportInterfaceController
    def index
    end

    def create
      GenerateVendorProviders.call
      redirect_to action: 'index'
    end
  end
end
