module SupportInterface
  module ApplicationForms
    module ApplicationChoices
      class BaseController < SupportInterfaceController
        def build_application_form
          @application_form = ApplicationForm.find(params[:application_form_id])
        end

        def build_application_choice
          @application_choice = @application_form.application_choices.find(params[:application_choice_id])
        end
      end
    end
  end
end
