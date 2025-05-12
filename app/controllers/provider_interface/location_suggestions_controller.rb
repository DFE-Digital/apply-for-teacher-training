module ProviderInterface
  class LocationSuggestionsController < ProviderInterfaceController
    def index
      return render(json: [], status: :bad_request) if params[:query].blank?

      render json: { suggestions: LocationSuggestions.new(params[:query]).call }
    end
  end
end
