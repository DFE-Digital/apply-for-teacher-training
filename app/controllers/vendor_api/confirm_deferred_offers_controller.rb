module VendorAPI
  class ConfirmDeferredOffersController < VendorAPIController
    include ApplicationDataConcerns

    def create
      ConfirmDeferredOffer.new(actor: audit_user,
                               application_choice: application_choice,
                               course_option: application_choice.current_course_option.in_next_cycle,
                               conditions_met: conditions_met).save!

      render_application
    end

  private

    def conditions_met
      params.require(:data).permit(:conditions_met).tap do |data|
        data.require(:conditions_met)
      end[:conditions_met]
    end
  end
end
