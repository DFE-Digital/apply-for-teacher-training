class LocationSuggestionsController < ApplicationController
  def index
    return render(json: { error: "Bad request" }, status: :bad_request) if params_invalid?

    suggestions = LocationSuggestion.suggest(params[:query])
    render json: suggestions
  end

private

  def params_invalid?
    params[:query].nil?
  end
end
