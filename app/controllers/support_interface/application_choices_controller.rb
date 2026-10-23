module SupportInterface
  class ApplicationChoicesController < SupportInterfaceController
    def show
      authorize(nil, :show?, policy_class: SupportInterface::CandidatePolicy)

      choice = ApplicationChoice.find(params.expect(:application_choice_id))
      redirect_to support_interface_application_form_path(choice.application_form)
    end
  end
end
