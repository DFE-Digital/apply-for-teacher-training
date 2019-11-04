module SupportInterface
  class ProvidersController < SupportInterfaceController
    def index
      @providers = Provider.all
    end

    def sync
      Rails.configuration.providers_to_sync[:codes].each do |code|
        SyncProviderFromFind.call(provider_code: code)
      end

      redirect_to action: 'index'
    end
  end
end
