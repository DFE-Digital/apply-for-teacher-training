module VendorApi
  class OffersController < VendorApiController
    rescue_from ActiveRecord::RecordNotFound, with: :application_not_found

    def create
      application_choice = ApplicationChoice.find(params[:application_id])

      make_an_offer = MakeAnOffer.new(application_choice: application_choice, offer_conditions: params[:data]).call
      if make_an_offer.successful?
        render json: { data: SingleApplicationPresenter.new(make_an_offer.application_choice).as_json }
      end
    end
  end
end
