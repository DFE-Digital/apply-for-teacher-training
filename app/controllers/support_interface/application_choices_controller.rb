module SupportInterface
  class ApplicationChoicesController < SupportInterfaceController
    def show
      choice = ApplicationChoice.find(params[:application_choice_id])
      redirect_to support_interface_application_form_path(choice.application_form)
    end
  end
end
