module SupportInterface
  class ProvidersController < SupportInterfaceController
    def index
      @providers = Provider.includes(:sites, :courses).all
    end

    def show
      @provider = Provider.includes(:courses, :sites).find(params[:provider_id])
    end

    def sync
      SyncFromFind.perform_async
      redirect_to action: 'index'
    end
  end
end
