module SupportInterface
  class ProvidersController < SupportInterfaceController
    def index
      @providers = Provider.includes(:sites, :courses).order(:name)
    end

    def show
      @provider = Provider.includes(:courses, :sites).find(params[:provider_id])
      @provider_agreement = ProviderAgreement.data_sharing_agreements.for_provider(@provider).last
    end

    def sync
      SyncFromFind.perform_async
      redirect_to action: 'index'
    end

    def open_all_courses
      @provider = Provider.find(params[:provider_id])

      @provider.courses.update_all(open_on_apply: true)

      flash[:success] = 'Successfully updated all courses'
      redirect_to support_interface_provider_path(@provider)
    end
  end
end
