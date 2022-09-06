module VendorAPI
  class DeferredOffersController < VendorAPIController
    include ApplicationDataConcerns

    def create
      DeferOffer.new(actor: audit_user, application_choice:).save!

      render_application
    end
  end
end
