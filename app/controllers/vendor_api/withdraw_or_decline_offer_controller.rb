module VendorAPI
  class WithdrawOrDeclineOfferController < VendorAPIController
    include ApplicationDataConcerns
    include APIValidationsAndErrorHandling

    def create
      service = DeclineOrWithdrawApplication.new(
        actor: audit_user,
        application_choice: application_choice,
      )

      if service.save!
        render_application
      else
        render_workflow_transition_error(service)
      end
    end
  end
end
