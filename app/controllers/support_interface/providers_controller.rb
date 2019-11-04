module SupportInterface
  class ProvidersController < SupportInterfaceController
    def index
      @providers = Provider.all
    end

    def sync
      # TODO: We're launching the pilot with these 3 providers, but at some point
      # we'll want to expand to others and we will need a better mechanism to
      # manage these.
      providers = %w[R55 1N1 S31]

      providers.each { |p| SyncProviderFromFind.call(provider_code: p) }
      redirect_to action: 'index'
    end
  end
end
