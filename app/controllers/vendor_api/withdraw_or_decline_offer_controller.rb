module VendorAPI
  class WithdrawOrDeclineOfferController < VendorAPIController
    include ApplicationDataConcerns

    def create
      DeclineOrWithdrawApplication.new(actor: audit_user,
                                       application_choice: application_choice).save!

      render_application
    end
  end
end
