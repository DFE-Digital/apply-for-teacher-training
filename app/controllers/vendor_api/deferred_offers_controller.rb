module VendorAPI
  class DeferredOffersController < VendorAPIController
    include ApplicationDataConcerns
    include APIValidationsAndErrorHandling

    def create
      DeferOffer.new(actor: audit_user, application_choice: application_choice).save!

      render_application
    end
  end
end
